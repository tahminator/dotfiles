#!/bin/zsh

# tmux-agents - live view of every omp agent, grouped by tmux session
# (sessions in tmux order, agents within a session by window/pane)
#
#   input    asking you a question / waiting on a tool approval
#   idle     finished its turn, waiting for your next prompt
#   working  busy
#
# state comes from the tmux-state omp extension (~/.omp/agent/extensions/tmux-state.ts);
# agents started before it was installed fall back to omp's pane title glyph (no age):
# "!" needs attention, ">" idle, anything else (spinner frame or ":") working.
#
# keys: every agent owns one jump key (1-9, then a-z skipping q) for its whole lifetime. a new
# agent takes the lowest free key; a key frees up when its omp process exits. the key is stored on
# the pane as @omp_key = "<key>:<omp pid>", so a different omp started later in the same pane gets
# a fresh assignment. q/esc quits. refreshes every 2s. bound to prefix+a as a popup in ~/.tmux.conf.
# * marks the agent in the pane you were on when you opened this popup (if any).

zmodload zsh/datetime

age() {
  local s=$1
  if (( s < 60 )); then echo "${s}s"
  elif (( s < 3600 )); then echo "$(( s / 60 ))m"
  else echo "$(( s / 3600 ))h$(( s % 3600 / 60 ))m"
  fi
}

# assignment order for new agents; q stays the quit key
jump_keys=({1..9} {a..p} {r..z})

# jump key -> tmux target / pane id, rebuilt every render
typeset -A jump_target jump_pane

# inside the popup this resolves to the client's active pane, i.e. the one you opened it from
current_pane=$(tmux display-message -p '#{pane_id}')

render() {
  # foreground omp process per tty: the identity that a key is bound to
  local -A omp_pid
  local tty stat pid comm
  while read -r tty stat pid comm; do
    [[ "$stat" == *+* && "${comm:t}" == omp && -z "$omp_pid[$tty]" ]] && omp_pid[$tty]=$pid
  done < <(ps -axo tty=,stat=,pid=,comm=)

  local -a rows unkeyed
  local -A used pane_key pane_pid
  local line id session winpane cmd state since title owned
  for line in "${(@f)$(tmux list-panes -a -F $'#{pane_id}\t#{session_name}\t#{window_index}.#{pane_index}\t#{pane_current_command}\t#{@omp_state}\t#{@omp_since}\t#{pane_tty}\t#{@omp_key}\t#{pane_title}')}"; do
    # split on tabs keeping empty fields
    local -a f=("${(@ps:\t:)line}")
    id=$f[1] session=$f[2] winpane=$f[3] cmd=$f[4] state=$f[5] since=$f[6] tty=$f[7] owned=$f[8] title=$f[9]
    if [[ "$cmd" != omp ]]; then
      # the agent that owned this key is gone; free it
      [[ -n "$owned" ]] && tmux set-option -p -u -t "$id" @omp_key
      continue
    fi

    pid=$omp_pid[${tty#/dev/}]
    pane_pid[$id]=$pid
    # keep the key only if the same omp process still owns it (and no other pane claimed it first)
    if [[ -n "$owned" && "${owned#*:}" == "$pid" && -z "$used[${owned%%:*}]" ]]; then
      pane_key[$id]=${owned%%:*}
      used[${owned%%:*}]=1
    else
      unkeyed+=("$id")
    fi

    # omp titles look like "π > title" (idle), "π ! title" (attention) or "π <spinner> title" (working)
    local glyph=""
    if [[ "$title" == "π "* ]]; then
      glyph="${title[3]}"
      title="${title[5,-1]}"
    fi
    if [[ -z "$state" ]]; then
      case $glyph in
        '!') state=input ;;
        ''|'>') state=idle ;;
        *) state=working ;;
      esac
      since=""
    fi

    rows+=("$session|$id|$winpane|$state|$since|$title")
  done

  # new agents take the lowest free key; past 34 agents the rest go keyless until one frees up
  local k
  for id in "${unkeyed[@]}"; do
    for k in "${jump_keys[@]}"; do
      [[ -n "$used[$k]" ]] && continue
      used[$k]=1
      pane_key[$id]=$k
      tmux set-option -p -t "$id" @omp_key "$k:$pane_pid[$id]"
      break
    done
  done

  jump_target=() jump_pane=()

  local out="" n=0 attention=0 color group="" target r
  local -a p
  for r in "${rows[@]}"; do
    # p: 1 session, 2 pane id, 3 window.pane, 4 state, 5 since, 6+ title
    p=("${(@s:|:)r}")
    session=$p[1] id=$p[2] state=$p[4] since=$p[5] title="${(j:|:)p[6,-1]}"
    target="$session:$p[3]"
    k=$pane_key[$id]

    if [[ "$session" != "$group" ]]; then
      out+=$'\e[1;34m'"$session"$'\e[0m\e[K\n'
      group=$session
    fi

    (( n++ ))
    [[ -n "$k" ]] && jump_target[$k]=$target jump_pane[$k]=$id

    case $state in
      input) color=$'\e[1;31m'; (( attention++ )) ;;
      idle) color=$'\e[1;33m'; (( attention++ )) ;;
      *) color=$'\e[2m' ;;
    esac
    local when="-"
    [[ -n "$since" ]] && when=$(age $(( EPOCHSECONDS - since )))

    local mark=" "
    [[ "$id" == "$current_pane" ]] && mark="*"

    out+=$(printf '%s %s %s%-8s\e[0m %6s  %-6s %s' "$mark" "${k:- }" "$color" "$state" "$when" "$p[3]" "$title")
    out+=$'\e[K\n'
  done

  # cursor home, redraw in place, clear the rest (avoids flicker)
  print -n $'\e[H'
  printf '\e[1m%d agent(s), %d need attention\e[0m\e[K\n\e[K\n' "$n" "$attention"
  (( n == 0 )) && print $'  no omp agents running\e[K'
  print -n "$out"
  print -n $'\e[K\n\e[2m1-9/a-z jump · q quit\e[0m\e[J'
}

jump() {
  [[ -n "$1" ]] || return 1
  tmux switch-client -t "$1" && tmux select-pane -t "$2"
}

print -n $'\e[?25l\e[2J'
trap 'print -n $'"'"'\e[?25h'"'"'' EXIT

while true; do
  render
  key=""
  read -s -t 2 -k 1 key
  case "$key" in
    q|$'\e') exit 0 ;;
    [1-9a-z]) jump "$jump_target[$key]" "$jump_pane[$key]" && exit 0 ;;
  esac
done
