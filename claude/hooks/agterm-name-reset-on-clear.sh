#!/bin/bash
# SessionStart (clear): drop the custom agterm session name so the sidebar label follows the terminal
# title again. An empty rename restores agterm's default naming; the old name belongs to the cleared topic.
set -u

[ -n "${AGTERM_SESSION_ID:-}" ] || exit 0
agtermctl session rename "" --target "$AGTERM_SESSION_ID" ${AGTERM_SOCKET:+--socket "$AGTERM_SOCKET"} \
  >/dev/null 2>&1
exit 0
