#!/usr/bin/env bash
# kill memory-hungry dev processes to recover RAM.

set -euo pipefail

java=true
node=true
go=true
omp=true
chrome=true
dry_run=false

usage() {
  cat <<'EOF'
usage: memk [--<target>=true|false ...] [--dry-run]

targets (all default to true):
  --java     every java process (jdtls, maven, gradle, ...)
  --node     every node process (tsserver, eslint, language servers, ...)
  --go       go toolchain: go, gopls, GOROOT tools, `go run` binaries
  --omp      every omp process except the one running this script
  --chrome   every Google Chrome tab (renderer processes; Chrome stays open)

  --dry-run  print what would be killed, kill nothing
EOF
}

for arg in "$@"; do
  case "$arg" in
  --dry-run) dry_run=true ;;
  -h | --help)
    usage
    exit 0
    ;;
  --java=* | --node=* | --go=* | --omp=* | --chrome=*)
    name=${arg%%=*}
    name=${name#--}
    value=${arg#*=}
    case "$value" in
    true | false) printf -v "$name" '%s' "$value" ;;
    *)
      echo "invalid value for --$name: '$value' (expected true or false)" >&2
      exit 1
      ;;
    esac
    ;;
  *)
    echo "unknown argument: $arg" >&2
    usage >&2
    exit 1
    ;;
  esac
done

# never kill this script or anything it runs under (e.g. the omp/shell that launched it)
protected=" $$ "
pid=$$
while [ "$pid" -gt 1 ]; do
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  [ -n "$pid" ] || break
  protected+="$pid "
done

goroot=""
if command -v go >/dev/null 2>&1; then
  goroot=$(go env GOROOT 2>/dev/null || true)
fi

# category for a process given its executable path (ps comm), empty if not targeted
classify() {
  local path=$1
  local base=${path##*/}
  case "$base" in
  java) [ "$java" = true ] && echo java ;;
  node) [ "$node" = true ] && echo node ;;
  omp) [ "$omp" = true ] && echo omp ;;
  "Google Chrome Helper (Renderer)") [ "$chrome" = true ] && echo chrome ;;
  go | gopls) [ "$go" = true ] && echo go ;;
  *)
    if [ "$go" = true ]; then
      if [ -n "$goroot" ] && [[ "$path" == "$goroot"/* ]]; then
        echo go
      elif [[ "$path" == */go-build*/* ]]; then
        echo go
      fi
    fi
    ;;
  esac
  return 0
}

targets=()
while read -r pid path; do
  [[ "$protected" == *" $pid "* ]] && continue
  category=$(classify "$path")
  [ -n "$category" ] || continue
  targets+=("$pid")
  rss_kb=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ' || true)
  printf '%-7s %7s  %6s MB  %s\n' "$category" "$pid" "$((${rss_kb:-0} / 1024))" "${path##*/}"
done < <(ps -axo pid=,comm=)

if [ ${#targets[@]} -eq 0 ]; then
  echo "nothing to kill"
  exit 0
fi

if [ "$dry_run" = true ]; then
  echo "dry run: would kill ${#targets[@]} process(es)"
  exit 0
fi

kill -TERM "${targets[@]}" 2>/dev/null || true

# give processes up to 3s to exit cleanly, then force-kill the rest
for _ in 1 2 3 4 5 6; do
  alive=()
  for pid in "${targets[@]}"; do
    kill -0 "$pid" 2>/dev/null && alive+=("$pid")
  done
  [ ${#alive[@]} -eq 0 ] && break
  sleep 0.5
done

if [ ${#alive[@]} -gt 0 ]; then
  echo "force-killing ${#alive[@]} process(es) that ignored SIGTERM"
  kill -KILL "${alive[@]}" 2>/dev/null || true
fi

echo "killed ${#targets[@]} process(es)"
