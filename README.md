
# Layers CLI

Layers CLI signs you in and binds this repository to the Layers Growth MCP, so your
coding agent can call Layers growth, content, paid-media and managed
distribution tools by name. One command does the whole setup, and no credential
is written into the repository.

## Get started

```text
Set up Layers Growth for me so you can plan, render and deliver content for this product from here.
1. Install the CLI: run `npm install -g @layers/cli`.
2. Set it up: run `layers setup` from this repository. It opens my browser once for sign-in and waits for me; it writes the `.mcp.json` entry and the Layers skill into the repo and stores the session in my OS credential store, so nothing secret lands in the repo.
3. Read the skill at `.agents/skills/layers/SKILL.md`, then tell me what to post first.
Let me know when it is ready.
```

Paste that into Claude Code, Codex, Cursor, or any coding agent working in your
repository: the agent runs both commands, and the browser sign-in is the only
step that needs a person.

This is what the agent sees when setup finishes:

```bash
$ cd your-app
$ layers setup

  ✓ Layers Growth MCP is configured and ready for this repository.

    Organization  org_…
    Project       prj_…
    Endpoint      https://mcp.layers.com/mcp

    Repository files
      .layers/project.json
      .mcp.json
      .agents/skills/layers/SKILL.md
      .claude/skills/layers -> ../../.agents/skills/layers
    These files are non-secret. The MCP client spawns `layers mcp`; the session stays in the credential store.
    Layers CLI     on_path
    Codex          registered
    Claude Code    project_config_pending_approval
    Readiness      ready
```

From there the agent reads the pinned skill pointer, loads the server-owned
skills for the job at hand, and calls the tools.

## Install

**Any platform with Node:**

```bash
npm install -g @layers/cli
```

**macOS:**

```bash
brew install layers/tap/layers
```

**Linux / macOS:**

```bash
curl -fsSL https://layers.com/install.sh | sh
```

The installer puts the binary in `$HOME/.local/bin` when that directory is on
your PATH, and in `/usr/local/bin` otherwise. Pass `--prefix` (or set
`LAYERS_INSTALL_DIR`) to choose the directory yourself, which is what a
container without sudo needs:

```bash
curl -fsSL https://layers.com/install.sh | sh -s -- --prefix "$HOME/.local/bin"
```

sudo runs only when the target directory needs it.

**Windows:**

```powershell
scoop bucket add layers https://github.com/layers/scoop-bucket
scoop install layers
```

**Direct download:** [GitHub Releases](https://github.com/layers/cli/releases)

## Manual setup

For people who prefer a shell:

```bash
# 1. Sign in and wire up this repository (opens a browser once)
cd your-app
layers setup

# 2. Call a tool right now, in this same shell
layers call find_growth_opportunities

# 3. Restart your coding agent, or run /mcp, so it loads the tools natively
```

Step 2 and step 3 are the same tools over the same sign-in. MCP clients read
`.mcp.json` at startup, so `layers call` is how you work in the session where
setup just ran.

## What `layers setup` writes

| File                             | What it is                                                       |
| -------------------------------- | ---------------------------------------------------------------- |
| `.layers/project.json`           | the public organization and project this repository is bound to  |
| `.mcp.json`                      | the `layers` MCP server, merged alongside servers already there  |
| `.agents/skills/layers/SKILL.md` | a thin pointer to the server-owned Layers skills                 |
| `.claude/skills/layers`          | a relative symlink to that pointer, where symlinks are supported |

The `.mcp.json` entry is the local command and nothing else:

```json
{
  "mcpServers": {
    "layers": { "command": "layers", "args": ["mcp"] }
  }
}
```

Setup is idempotent. Re-running it repairs Layers-owned entries, leaves every
other byte of `.mcp.json` alone, and never creates a second project. It also
removes the retired `growth` server entry when that entry is exactly the one an
older `layers setup` wrote, and refuses to touch one that was modified.

`.layers/project.json` holds public selectors, not authority. The MCP edge
revalidates the session and its membership on every call.

## The endpoint, and pointing it somewhere else

`layers mcp` forwards to `https://mcp.layers.com/mcp`. For local development,
set `LAYERS_MCP_HOST` (or pass `--host` to `layers setup`) to another
deployment:

```bash
LAYERS_MCP_HOST=https://localhost:8787 layers setup
```

`--host` records the choice in the machine's global Layers config, so the
`layers mcp` the client spawns reaches the same place without an environment
variable. The endpoint is machine-owned in both cases: nothing in a repository
can select one, because a repository is shared and a credential destination is
not. Only the production host, an `https://*.layers.com` host, loopback, and the
host named in `LAYERS_MCP_HOST` are accepted.

## No credential in the repository

`layers login` stores your session in the operating system keyring: Keychain on
macOS, Credential Manager on Windows, `gnome-keyring` or `kwallet` on Linux.
The credential subsystem also maintains its mode-0600 machine record under the
global Layers config directory for refresh durability. The Layers Growth MCP will not
accept that record without the matching OS-keyring session unless the operator
explicitly records `--allow-file-credentials` in the 0600 machine config.

`layers mcp` and `layers call` are the credential's only readers. An MCP client
spawns the proxy, which forwards JSON-RPC messages with that session. The
repository holds the command name and the public binding only, so `grep -r` of
the project finds no credential.

There is no API key in MCP setup, and no command that mints one. Partner API
keys remain available for REST integrations and are issued from the Layers app.

## Credits

Prices are the server's, and the catalog carries them. Every priced tool
accepts a cost check that returns the exact price of those arguments without
running the call, and every result carries what it cost and what is left. This
binary holds no price, plan, or trial fact.

A workspace `layers setup` just created has no subscription, so charged calls
are refused until someone chooses a plan. Setup reads `layers://account` after
it binds, and when that workspace is not spend-entitled it prints the plan page
alongside the connect-account step:

```
Next steps for your coding agent
  Choose a plan: https://app.layers.com/?settings=plan
```

The line names the page and nothing else. What a plan costs, what it includes,
and how it starts are on that page and in `layers://account`.

`layers setup --json` carries the same step in `human_actions`:

```json
{
  "human_actions": [
    {
      "kind": "choose_plan",
      "url": "https://app.layers.com/?settings=plan",
      "message": "Choose a plan: https://app.layers.com/?settings=plan"
    }
  ]
}
```

The key is always present; it is an empty array once the workspace can spend.

## JSON output

`layers call` prints the tool's structured envelope verbatim on stdout, which is
what makes it safe to pipe into an agent. On a tool error it exits 1 and writes
the code and message to stderr, while the full error envelope still goes to
stdout so `recovery_tool` and `nextSteps` stay readable.

Every other command takes `--json` too, and answers with one JSON object on
stdout, so an agent reads a result instead of parsing a table:

```bash
$ layers setup --json
{
  "root": "/Users/you/your-app",
  "status": "ready",
  "endpoint": "https://mcp.layers.com/mcp",
  "organization_id": "org_…",
  "project_id": "prj_…",
  "written": ["…/.layers/project.json", "…/.mcp.json", "…/.agents/skills/layers/SKILL.md"],
  "readiness": { "status": "ready" }
}
```

`layers setup --new` has a second result that also exits zero. Onboarding can
stop on one fact no source can provide — most often the product's public URL —
and that is a question rather than a failure. Branch on `status`; a `ready`
object is the one above, and this one is the stop:

```bash
$ layers setup --new --org org_… --json
{
  "root": "/Users/you/your-app",
  "status": "needs_answer",
  "endpoint": "https://mcp.layers.com/mcp",
  "rerun": "layers setup --new --org org_… --url <their URL>",
  "rerun_no_public_url": "layers setup --new --org org_… --no-public-url",
  "workspace": {
    "state": "needs_input",
    "question": {
      "question_id": "public_url.…",
      "ask": "Is one of these the public URL Layers can use to onboard Widget?",
      "options": [{ "option_id": "url_1", "label": "https://…" }]
    }
  }
}
```

Nothing was written: no binding, no `.mcp.json` entry, no skill. Put
`workspace.question.ask` and its option labels to the person you are working
for, then run one of the two lines. `rerun` carries the literal `<their URL>`
placeholder, so replace it with the address they give before running it;
`rerun_no_public_url` is a command as it stands.

Without the flag the output is formatted text. With it, progress lines move to
stderr so stdout carries the object alone, and a failure prints one object on
stderr with a non-zero exit status:

```json
{
  "error": {
    "code": "login_required",
    "message": "Not logged in to Layers. Run `layers login`"
  }
}
```

`layers mcp` is a stdio proxy that prints no result of its own, so the flag
does nothing there.

## Privacy

Setup writes the four non-secret files above. The `.mcp.json` entry contains no
endpoint or credential policy; those remain machine-owned. Credentials use a
writable key derived from environment, issuer, OAuth client, user, binary, MCP
origin, and OAuth origin, so production, staging, local development, and the
internal `cora` binary never share one. The token identity and the repository
binding are rechecked before each forwarded request. Setup does not upload or
scan source code.

Claude Code discovers the repository `.mcp.json` entry but keeps a new project
server pending until the user approves it. Setup reports that state explicitly;
start `claude` in the repository and approve the exact `layers mcp` entry once.
Layers never edits Claude Code's private trust state.

[Read the full privacy model](https://layers.com/privacy)

## All commands

### MCP

| Command                     | What it does                                                           | `--json` object                         |
| --------------------------- | ---------------------------------------------------------------------- | --------------------------------------- |
| `layers setup`              | Sign in and wire this repository to the Layers Growth MCP              | bindings, files, clients, and readiness |
| `layers call <tool> [json]` | Call a repository-bound Layers tool from the shell                     | the tool's structured envelope          |
| `layers mcp`                | Serve the Layers Growth MCP to a client over credential-isolated stdio | nothing; a stdio proxy prints no result |

`layers setup` flags: `--org` and `--project` to select the binding, `--new` to
create the first workspace for an account that has no project, `--host` (or
`LAYERS_MCP_HOST`) to point at another deployment, `--credential-dir` to choose
a machine-owned credential directory, `--allow-file-credentials` to consent to
the 0600 file fallback, and `--require-keyring` to withdraw that consent. On
Windows the credential store is pinned to the current user's profile-backed
Layers directory; custom roots and `XDG_CONFIG_HOME` are rejected until ancestor
ACL validation is certified.

Ids are the public `org_…` and `prj_…` selectors everywhere they are printed,
including `layers org list --json`. Both that form and the bare uuid are
accepted wherever an id is an input.

### Creating the first workspace

An account with no project has nothing to select, so `layers setup` creates one.
It reads the product name and one-line description this repository can answer
for itself, from a package manifest, the README title, and the README's first
paragraph, and shows them. No file, path, or source line leaves the machine.

It then sends that brief and says so:

```
  Sending this brief to Layers.
  Layers confirms the workspace with the account owner in the browser.
```

There is no terminal question, so the run behaves the same in a shell with no
tty, which is where a coding agent runs. A repository whose README describes
nothing gets a refusal naming the repair instead of an invented description.
`--accept-brief` is still accepted and does nothing.

### Auth

| Command                   | What it does                                                | `--json` object                             |
| ------------------------- | ----------------------------------------------------------- | ------------------------------------------- |
| `layers login`            | Sign in via browser                                         | the account signed in                       |
| `layers login --headless` | Sign in without opening a browser or listening on localhost | the account signed in                       |
| `layers logout`           | Sign out of this repository's Layers Growth MCP session     | which stores were cleared, and what remains |
| `layers whoami`           | Show the current user, resolving the session first          | the session state and the account           |
| `layers auth status`      | Session health, expiry, and the recent auth trail           | the same report `--json` always printed     |
| `layers auth log`         | Timestamped refresh / adopt / quarantine / revoke history   | the events and the log path                 |
| `layers auth restore`     | Reverse a credential quarantine, no browser needed          | what was restored, and whether it expired   |

`layers logout` clears the credential this repository's Layers Growth MCP uses and
names it. When the same account is still signed in to the shared `layers login`
session on this machine, the report says so; `layers logout --all` clears that
one too. A malformed or foreign `.mcp.json` never blocks a logout.

Every session command takes `--credential-dir`, `layers logout` included. That
directory is the store: deleting it ends the session for every command, and
nothing falls back to another one. `--all` clears the plain store of the
directory it was given, so a scoped run's follow-up carries the flag too:
`layers logout --all --credential-dir <dir>`.

### CLI

| Command          | What it does                         | `--json` object                                   |
| ---------------- | ------------------------------------ | ------------------------------------------------- |
| `layers update`  | Update the CLI to the latest version | the versions, and whether an update was installed |
| `layers version` | Show version info                    | version, build date, commit, Go version, platform |

Once a day, after a command has finished, the CLI checks the latest published
release and prints one line to stderr when your binary is behind:

```
layers 2.0.0 is behind 2.0.2. Run `layers update`.
```

The API can also report a minimum version in the `X-Layers-CLI-Floor` response
header. The CLI prints the same line for that, on any command, without waiting
for the daily window.

The line is silent when your binary is current, when the check fails, when
stdout is not a terminal, when the command answers in JSON, and when
`LAYERS_NO_UPDATE_CHECK` is set:

```bash
export LAYERS_NO_UPDATE_CHECK=1
```

The check never blocks a command. It runs after the output, with a two-second
timeout, and the last attempt is stamped at
`~/.config/layers/update-check.json` (or `$XDG_CONFIG_HOME/layers/`).

## Troubleshooting

**Can't sign in?** Make sure ports 54321-54323 aren't in use. The CLI opens your
browser and listens for the OAuth callback on localhost.

**"the sign-in link expired after 5 minutes"?** The CLI waits five minutes for
the browser to come back. A first-time signup inside that window is email, full
name, the code mail, the code, and an Authorize click. Run `layers login` again
and it reopens with a fresh link.

**Signing in over SSH or on a headless machine?** Run `layers login --headless`,
open the printed URL on any device, then paste the localhost callback URL (or
its `code` value) into the CLI.

**`BOOTSTRAP_NOT_AVAILABLE`?** The Layers edge is not offering workspace
creation at that moment. Nothing local repairs it: try again later, or send
support@layers.com the request id the message carries.

**Agent can't see the Layers tools?** Restart it, or run `/mcp`. MCP servers are
read at startup, so a `.mcp.json` written mid-session is not picked up until
then. `layers call <tool>` works immediately in the meantime.

**`layers` is not on your PATH?** An MCP client cannot spawn `layers mcp` until
it is. Install with `npm install -g @layers/cli`, or put the binary's directory
on PATH.

**`mcpServers.growth names the retired growth MCP`?** This repository was wired
to the retired growth service. Run `layers setup`; it removes that entry when it
is exactly the one an older `layers setup` wrote, and tells you what to fix when
somebody edited it.

**`WORKSPACE_NOT_BOUND`?** You are not in a repository `layers setup` ran in.
The binding lands at the repository root, so run `layers setup` from there.

**Session problems?** `layers auth status` reports the state, the expiry, and
what repairs it. `layers auth restore` reverses a quarantine without a browser.
`layers login` repairs the session every command reads, this repository's MCP
session included, so `whoami`, `org` and `call` agree after it.

**`layers mcp` says the endpoint it was set up for is unreachable?** Setup
records the endpoint it resolved in the machine's config, and `.mcp.json` never
names one, so a repository cannot decide where your session goes. If that record
is missing or stale, rerun `layers setup` (with `--host` if you use a
non-default deployment) in the repository to write it again.

**Keychain errors on Linux?** Install `gnome-keyring` or `kwallet`. Setup blocks
by default; `--allow-file-credentials` explicitly permits the mode-0600 machine
record under `~/.config/layers/`. It is not encrypted and is never stored in the
repository.

## Links

- [Layers](https://layers.com): the main site
- [Docs](https://layers.com/docs): install, catalog, and error recovery
- [Dashboard](https://app.layers.com): the web dashboard
- [Changelog](https://github.com/layers/cli/releases): release notes

## License

MIT
