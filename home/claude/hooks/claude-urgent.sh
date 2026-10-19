#!/usr/bin/env bash
# Toujours exit 0 : sur le hook Stop, un exit 2 empêcherait Claude de s'arrêter.
cat >/dev/null

window_pids=$(swaymsg -t get_tree 2>/dev/null | jq -r '.. | .pid? // empty')
pid=$PPID
while [ "${pid:-1}" -gt 1 ]; do
  if grep -qx "$pid" <<<"$window_pids"; then
    swaymsg "[pid=$pid] urgent enable" >/dev/null 2>&1
    break
  fi
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done
exit 0
