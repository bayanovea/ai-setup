# Isolated headless `claude -p` on a subscription

For scripts, hooks and tools that call `claude -p` as a plain LLM: the call must see only what the
script sends, with none of my global rules, hooks, plugins, MCP servers or memory. Verified on Claude
Code 2.1.309.

## Why not `--bare`

`--bare` is the built-in clean mode (no hooks, no `CLAUDE.md` discovery, no plugins), but it
authenticates only with `ANTHROPIC_API_KEY` or an `apiKeyHelper`. OAuth and the keychain are never
read, so a subscription login does not work with it.

## Recipe

1. A dedicated config dir per tool, logged in once. Run the login from a neutral folder, so the
   folder-trust question does not concern a project:

   ```sh
   mkdir -p ~/.config/<tool>/claude
   cd /tmp
   CLAUDE_CONFIG_DIR=~/.config/<tool>/claude claude
   ```

   Pick "Claude account with subscription", finish the browser login, `/exit`. The main login in
   `~/.claude` is unaffected; `claude auth status` (with or without the env var) shows each one.

2. Every call:

   ```sh
   CLAUDE_CONFIG_DIR=~/.config/<tool>/claude claude -p --model sonnet \
     --tools "" --strict-mcp-config --setting-sources "" --no-session-persistence \
     --system-prompt "$SYSTEM" --output-format json --json-schema "$SCHEMA" < prompt.txt
   ```

   run from a fresh empty temp dir, with `ANTHROPIC_API_KEY` removed from the environment.

| Piece | What it blocks |
|---|---|
| `CLAUDE_CONFIG_DIR` | user hooks, plugins, MCP servers, `~/.claude/CLAUDE.md`, auto-memory, settings |
| empty temp cwd | the project's `CLAUDE.md`, `.claude/settings*.json`, `.mcp.json` |
| `--setting-sources ""` | `CLAUDE.md` files in **ancestor** directories of the cwd (see below) |
| `--tools ""` | any file, shell or web access; the model sees only the prompt |
| `--strict-mcp-config` | MCP servers, even if the config dir gains some later |
| `--no-session-persistence` | transcripts of the (possibly private) prompt on disk |
| `--system-prompt` | Claude Code's default agent prompt |
| `--model` | the default, which is the most expensive model |
| unset `ANTHROPIC_API_KEY` | silently billing an API key instead of the subscription |

## Structured output

With `--output-format json --json-schema '<schema>'` the result envelope carries the parsed object
in `structured_output`, and the same JSON as text in `result`. Check `is_error` and the exit code
first; a missing login shows up there and mentions `/login`.

```python
env = {**os.environ, "CLAUDE_CONFIG_DIR": str(config_dir)}
env.pop("ANTHROPIC_API_KEY", None)
with tempfile.TemporaryDirectory() as cwd:
    r = subprocess.run(cmd, input=prompt, cwd=cwd, env=env,
                       capture_output=True, text=True, timeout=120)
envelope = json.loads(r.stdout)
answer = envelope.get("structured_output") or json.loads(envelope["result"])
```

## Pitfalls found

- **Ancestor `CLAUDE.md` leaks in.** A `CLAUDE.md` in the parent of the temp cwd was loaded and
  obeyed (canary: "end every reply with PELICAN"). The init event still reported `claude_md: null`,
  so it is not a reliable check. `--setting-sources ""` stops it.
- **Skills are still listed** in the init event, but with `--tools ""` there is no Skill tool to
  run them. Built-in plugins (`cc-plugin-*@builtin`) always load; user plugins do not.
- **No stdin:** without piped input the CLI waits 3 s and warns. Pipe the prompt, or `< /dev/null`.
- **Language drift:** English questions sometimes got German answers (2 of 31) although the system
  prompt said "answer in the language of the question". Naming the language at the end of the user
  prompt ("Write the answer in English.") cut it to 1 of 31, not to zero.
- **Latency:** 4-6 s per call for a prompt of ~8 KB.

## Verifying isolation

- `--output-format stream-json --verbose`: the `system/init` event lists `tools`, `mcp_servers`,
  `plugins`. Expect empty tools, empty MCP servers, built-in plugins only.
- Canary: put a `CLAUDE.md` with an odd instruction in the parent of the cwd and check the answer
  ignores it.
- Hooks: check that files a user hook writes (logs, corpora, journals) do not change after a call.
- `claude auth status` with the env var shows the isolated login; without it, the main one.
