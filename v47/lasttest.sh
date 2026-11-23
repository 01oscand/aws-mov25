#!/usr/bin/env bash
# G-v47: kör ENDAST på EC2-instans i din egen novatrix-web-asg.
set -euo pipefail
DURATION="${1:-600}"
if ! [[ "$DURATION" =~ ^[0-9]+$ ]] || ((DURATION < 30 || DURATION > 900)); then
  echo "Användning: bash lasttest.sh [30-900 sekunder]" >&2
  exit 2
fi
pids=()
cleanup() {
  for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
  wait 2>/dev/null || true
  echo "CPU-testet avslutat och underprocesserna stoppade."
}
trap cleanup EXIT INT TERM
for i in 1 2; do
  (while :; do :; done) &
  pids+=("$!")
done
echo "Belastar CPU i $DURATION sekunder med 2 workers. Avbryt med Ctrl+C."
sleep "$DURATION"
