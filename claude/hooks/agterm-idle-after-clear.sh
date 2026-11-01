#!/bin/bash
# Notification (idle_prompt): acknowledge agterm's unseen badge for the idle ping of a session that
# has no reply yet, i.e. right after /clear. Claude Code cannot mute just this ping, and muting the
# channel would also kill the useful ones.
set -u

[ -n "${AGTERM_SESSION_ID:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

transcript="$(jq -r '.transcript_path // empty')"
[ -f "$transcript" ] && grep -qm1 '^{"type":"assistant"\|,"type":"assistant"' "$transcript" && exit 0

sleep 1 # the hook may run before the terminal notification reaches agterm
agtermctl session seen --target "$AGTERM_SESSION_ID" ${AGTERM_SOCKET:+--socket "$AGTERM_SOCKET"} >/dev/null 2>&1
exit 0
