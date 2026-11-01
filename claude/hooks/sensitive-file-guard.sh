#!/usr/bin/env bash
# PreToolUse/Read guard: hard-stop (ask for explicit approval) when the target
# looks like a secrets / credentials / private-key file.
# Narrow on purpose — matches file NAMES/paths only, never content, so it does
# not fire on the IPs/hostnames/URLs that are pervasive in normal source.
# Input: hook JSON on stdin. Output: PreToolUse permission decision on match.

set -euo pipefail

payload="$(cat)"

# Extract tool_input.file_path without a hard jq dependency.
fp="$(printf '%s' "$payload" \
  | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -n1 \
  | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')"

[ -z "$fp" ] && exit 0

lp="$(printf '%s' "$fp" | tr '[:upper:]' '[:lower:]')"
bn="${lp##*/}"

flag=0

# Path / extension based key & credential material.
case "$lp" in
  *.pem|*.key|*.p12|*.pfx|*.pkcs12|*.keystore|*.jks|*.kdbx|*.ppk|*.asc|*.gpg) flag=1 ;;
  */id_rsa|id_rsa|*/id_dsa|id_dsa|*/id_ecdsa|id_ecdsa|*/id_ed25519|id_ed25519) flag=1 ;;
  */.netrc|.netrc|*/.pgpass|.pgpass|*/.htpasswd|*/.npmrc|.npmrc|*/.pypirc) flag=1 ;;
  */credentials|credentials|*/.aws/credentials|*/.aws/config) flag=1 ;;
  */.gnupg/*|*/localconf.d/*) flag=1 ;;
esac

# .env family, but allow templates.
case "$bn" in
  .env|.env.*)
    case "$bn" in
      *.example|*.sample|*.template|*.dist|*.md) ;;
      *) flag=1 ;;
    esac ;;
esac

# secrets-named config files, but not source that merely handles secrets.
case "$bn" in
  *.secret|*.secrets|secret.*|secrets.*)
    case "$bn" in
      *.go|*.ts|*.tsx|*.js|*.jsx|*.py|*.php|*.java|*.rb|*.rs|*.kt|*.swift) ;;
      *) flag=1 ;;
    esac ;;
esac

[ "$flag" -eq 0 ] && exit 0

# JSON-escape the path for the reason string.
esc="$(printf '%s' "$fp" | sed 's/\\/\\\\/g; s/"/\\"/g')"

printf '{"systemMessage":"⛔🚨 ALARM — sensitive-looking file read paused, needs your approval: %s","hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"⛔🚨 ALARM: \\"%s\\" looks like a secrets / credentials / keys file. Reading it needs your explicit, conscious approval — approve only if you truly intend to expose this content to the model."}}\n' "$esc" "$esc"
exit 0
