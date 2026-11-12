#!/bin/zsh

# omp-restart - restart every omp running in a tmux pane, resuming the session each was on
#
#   omp-restart      restart them all
#   omp-restart -n   dry run: print what would happen
#
# which session each omp is on comes from the @omp_session pane option ("<pid>:<file>"), set by
# the tmux-state extension (~/.omp/agent/extensions/tmux-state.ts). omps started before that
# existed fall back to lsof: the session .jsonl they hold open for writing (an omp only opens it
# on its first write, so an untouched freshly-resumed omp there has nothing to find).
#
# each omp gets SIGTERM, and once its pane is back at the shell prompt `omp --resume <file>` is
# typed into it. an omp with no session on disk (never prompted) comes back as plain `omp`.
#
# skipped: omps outside tmux (nowhere to type the relaunch), and the omp this script runs
# under (killing it would kill this script before the relaunch).

dry_run=0
case "$1" in
  -n) dry_run=1 ;;
  '') ;;
  *) echo "usage: omp-restart [-n]" >&2; exit 2 ;;
esac

sessions_dir="${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/sessions"
# resolve symlinks to match the paths lsof reports (/tmp is /private/tmp on macOS)
sessions_dir=${sessions_dir:A}

panes=("${(@f)$(tmux list-panes -a -F $'#{pane_id}\t#{pane_tty}\t#{session_name}:#{window_index}.#{pane_index}\t#{pane_current_command}\t#{@omp_session}' 2>/dev/null)}") ||
  { echo "No tmux server running" >&2; exit 1; }

# tty -> pane for panes whose foreground program is omp
typeset -A tty_pane tty_target tty_session
local line
for line in "${panes[@]}"; do
  local -a f=("${(@ps:\t:)line}")
  [[ "$f[4]" == omp ]] || continue
  tty_pane[${f[2]#/dev/}]=$f[1]
  tty_target[${f[2]#/dev/}]=$f[3]
  tty_session[${f[2]#/dev/}]=$f[5]
done

# omps this script is running under
typeset -A ancestors
pid=$$
while (( pid > 1 )); do
  ancestors[$pid]=1
  pid=$(ps -o ppid= -p $pid | tr -d ' ')
  [[ -n "$pid" ]] || break
done

# foreground omp per tty (workers/daemons have no tty and no + in stat)
local -a todo
local tty stat comm
while read -r tty stat pid comm; do
  [[ "$stat" == *+* && "${comm:t}" == omp ]] || continue
  if [[ -z "$tty_pane[$tty]" ]]; then
    echo "skip pid $pid ($tty): not in tmux; use /reload there"
  elif [[ -n "$ancestors[$pid]" ]]; then
    echo "skip pid $pid ($tty_target[$tty]): this script runs inside it; use /reload there"
  else
    todo+=("$pid $tty")
  fi
done < <(ps -axo tty=,stat=,pid=,comm=)

(( ${#todo} )) || { echo "No omp to restart"; exit 0; }

# session file of an omp: what its pane published if it is from this same process, else the one
# it has open (top level of sessions/<dir>/, not subagent files nested deeper)
session_of() {
  local pid=$1 published=$tty_session[$2]
  if [[ "${published%%:*}" == "$pid" ]]; then
    print -r -- "${published#*:}"
    return
  fi
  lsof -Fn -p $pid 2>/dev/null | sed -n 's/^n//p' |
    grep -E "^${sessions_dir}/[^/]+/[^/]+\.jsonl$" | head -n 1
}

typeset -A cmd_of
local entry session_file
for entry in "${todo[@]}"; do
  read -r pid tty <<<"$entry"
  session_file=$(session_of $pid $tty)
  if [[ -n "$session_file" && -f "$session_file" ]]; then
    cmd_of[$pid]="omp --resume ${(q)session_file}"
  else
    cmd_of[$pid]="omp"
  fi
  echo "$tty_target[$tty] (pid $pid): $cmd_of[$pid]"
done

(( dry_run )) && exit 0

for entry in "${todo[@]}"; do
  kill -TERM ${entry%% *}
done

local pane i restarted=0 failed=0
for entry in "${todo[@]}"; do
  read -r pid tty <<<"$entry"
  pane=$tty_pane[$tty]
  # wait up to 10s for the omp to exit and its pane to drop back to the shell
  for (( i = 0; i < 100; i++ )); do
    if ! kill -0 $pid 2>/dev/null &&
      [[ "$(tmux display-message -p -t $pane '#{pane_current_command}')" != omp ]]; then
      break
    fi
    sleep 0.1
  done
  if (( i == 100 )); then
    echo "pid $pid ($tty_target[$tty]) did not exit; left alone" >&2
    (( failed++ ))
    continue
  fi
  tmux send-keys -t $pane -l "$cmd_of[$pid]" && tmux send-keys -t $pane Enter
  (( restarted++ ))
done

if (( failed )); then
  echo "Restarted $restarted omp(s), $failed failed" >&2
  exit 1
fi
echo "Restarted $restarted omp(s)"
