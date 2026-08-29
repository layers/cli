
# Layers CLI

Layers CLI signs you in and hands your coding agent research tools for TikTok
and Instagram, scoped to the repository you run it in. Search a niche, find the
posts that beat their own account's normal, read the creative anatomy of the
winners, register what you publish, then read the outcome a day later.

Research runs on public data, so there is no social account to connect. One
command does the whole setup, and no key is written to any file.

```bash
$ cd your-app
$ layers setup

  ✓ Growth is set up for this repository.

    Account   you@example.com
    Balance   0 credits
    Plan      free

    Wrote
      .mcp.json
      .claude/skills/growth/SKILL.md
    .mcp.json names the local command `layers mcp` and nothing else; no key was written anywhere.

  Start your trial
    3-day free Pro trial: $0 today, card required, 100 credits, then $49/mo unless cancelled.

  https://growth.layers.com/v1/checkout?item=trial&acct=…

  Your coding agent can call the growth tools RIGHT NOW from this shell.
    layers growth <tool> '{"query":"dream meaning"}'
```

Then ask your agent to grow the app. It reads the codebase it already knows,
builds the brief itself, and runs the research loop: post and hashtag search,
competitor and adjacent-account mapping, breakout-post deconstruction, and the
outcome check a day after you publish.

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

## Quick start

```bash
# 1. Sign in and wire up this repository (opens a browser once)
cd your-app
layers setup

# 2. Call a tool right now, in this same shell
layers growth growth_search_posts '{"query":"dream meaning","limit":5}'

# 3. Restart your coding agent, or run /mcp, so it loads the tools natively

# 4. Check what you have left whenever you want
layers account
```

Step 2 and step 3 are the same tools over the same sign-in. MCP clients read
`.mcp.json` at startup, so `layers growth` is how you work in the session where
setup just ran.

## What `layers setup` writes

| File                             | What it is                                                      |
| -------------------------------- | --------------------------------------------------------------- |
| `.mcp.json`                      | the `growth` MCP server, merged alongside servers already there |
| `.claude/skills/growth/SKILL.md` | the research loop your agent follows                            |

The `.mcp.json` entry is the local command and nothing else:

```json
{
  "mcpServers": {
    "growth": { "command": "layers", "args": ["mcp"] }
  }
}
```

Pass `--name`, `--description` or `--keywords` and setup also records an app
brief at `.layers/growth.json` for later tools.

## No key on disk

`layers login` stores your session in the operating system keyring: Keychain on
macOS, Credential Manager on Windows, `gnome-keyring` or `kwallet` on Linux.

`layers mcp` is the credential's only reader. Your MCP client spawns it, and it
forwards every JSON-RPC message to `https://growth.layers.com/mcp` with that
session. The repository holds the command name and nothing else, so `grep -r`
of your project finds no credential.

For the rare client you wire by hand and that cannot spawn a local command,
`layers keys create` mints a long-lived key, prints it exactly once, and writes
it to no file. Five keys may be active at a time; `layers keys revoke <keyId>`
ends one.

## Credits

Every `growth_*` result carries what it cost and what is left. `layers account`
reports the same balance without an agent attached:

```bash
$ layers account

  Growth account
    Balance   0 credits
    Plan      free
    Trial     https://growth.layers.com/v1/checkout?item=trial&acct=…
```

A new account starts at 0 credits. The 3-day Pro trial costs $0 today, requires
a card, and adds 100 credits. It renews to Pro, $49/month with 5,000 monthly
credits, unless cancelled. Ultra is $199/month with 25,000 monthly credits.
Subscribers can buy one-time packs: 500 credits for $5, 1,000 for $9, 2,000 for
$17, or 4,000 for $29.

Every priced tool accepts `get_cost: true` and returns the exact price of those
arguments without running the call. Cache hits cost nothing, and a failed call
refunds automatically. The server generates the current price of every tool at
<https://growth.layers.com>.

## JSON output

`layers growth` prints the tool's JSON envelope verbatim on stdout, which is
what makes it safe to pipe into an agent. On a tool error it exits 1 and writes
the code and message to stderr, while the full error envelope still goes to
stdout so `recovery_tool` and `nextSteps` stay readable.

Every other command takes `--json` too, and answers with one JSON object on
stdout, so an agent reads a result instead of parsing a table:

```bash
$ layers account --json
{
  "configured": true,
  "balance": 0,
  "plan": "free",
  "trial_url": "https://growth.layers.com/v1/checkout?item=trial&acct=…",
  "source": ".mcp.json"
}
```

Without the flag the output is the formatted text it has always been. With it,
progress lines move to stderr so stdout carries the object alone, and a failure
prints one object on stderr with a non-zero exit status:

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

The CLI sends your Layers session to the growth service to resolve your account
and to make each call. It writes the two files above and reads nothing else.
It does not read, upload, or scan your source. Your coding agent reads the
codebase, locally, as it already does, and decides what to put in the research
brief.

[Read the full privacy model](https://layers.com/privacy)

## All commands

### Growth

| Command                       | What it does                                                           | `--json` object                                  |
| ----------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------ |
| `layers setup`                | Sign in and wire the `growth_*` tools into this repository             | what it wrote, and the account those files reach |
| `layers growth <tool> [json]` | Call a `growth_*` tool with your Layers session and print its envelope | the tool's envelope, unchanged by the flag       |
| `layers mcp`                  | Serve the growth tools to an MCP client over stdio                     | nothing; a stdio proxy prints no result          |
| `layers account`              | Show this repository's growth credit balance and plan                  | balance, plan, trial, and the file it read       |

`layers setup` flags: `--name`, `--description`, `--keywords a,b,c`, and
`--host` (or the `LAYERS_GROWTH_HOST` environment variable) to point at a
non-production deployment.

### Auth

| Command                   | What it does                                                | `--json` object                           |
| ------------------------- | ----------------------------------------------------------- | ----------------------------------------- |
| `layers login`            | Sign in via browser                                         | the account signed in                     |
| `layers login --headless` | Sign in without opening a browser or listening on localhost | the account signed in                     |
| `layers logout`           | Sign out                                                    | whether a session ended, and whose        |
| `layers whoami`           | Show the current user, resolving the session first          | the session state and the account         |
| `layers auth status`      | Session health, expiry, and the recent auth trail           | the same report `--json` always printed   |
| `layers auth log`         | Timestamped refresh / adopt / quarantine / revoke history   | the events and the log path               |
| `layers auth restore`     | Reverse a credential quarantine, no browser needed          | what was restored, and whether it expired |

### Keys

`layers setup` and `layers growth` never need a key. These are for clients you
wire by hand.

| Command                      | What it does                                 | `--json` object                |
| ---------------------------- | -------------------------------------------- | ------------------------------ |
| `layers keys create`         | Mint a growth API key and print it once      | the minted key, printed once   |
| `layers keys list`           | List growth API keys for your Layers account | the keys, each with its status |
| `layers keys revoke <keyId>` | Revoke a growth API key                      | the key revoked                |

`layers keys create` flags: `--project` to bind the key to a platform project,
`--name` to pick the matching project by app name.

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

**Signing in over SSH or on a headless machine?** Run `layers login --headless`,
open the printed URL on any device, then paste the localhost callback URL (or
its `code` value) into the CLI.

**Agent can't see the `growth_*` tools?** Restart it, or run `/mcp`. MCP servers
are read at startup, so a `.mcp.json` written mid-session is not picked up until
then. `layers growth <tool>` works immediately in the meantime.

**`layers` is not on your PATH?** An MCP client cannot spawn `layers mcp` until
it is. Install with `npm install -g @layers/cli`, or put the binary's directory
on PATH.

**`No growth MCP configured here`?** You are not in the repository `layers
setup` ran in. The files land at the repository root, so run `layers account`
from anywhere inside that repo.

**A tool answered `NO_KEY`?** Nobody is signed in. Run `layers login`.

**A tool answered `NO_ACCOUNT`?** You are signed in and the Layers account is
not ready for growth. The message names the fix; signing in again is not it.

**Session problems?** `layers auth status` reports the state, the expiry, and
what repairs it. `layers auth restore` reverses a quarantine without a browser.

**Keychain errors on Linux?** Install `gnome-keyring` or `kwallet`. Falls back
to encrypted file storage at `~/.config/layers/`.

## Links

- [Layers](https://layers.com): the main site
- [Growth docs](https://layers.com/docs/growth): install, prices, and error recovery
- [Dashboard](https://app.layers.com): the web dashboard
- [Changelog](https://github.com/layers/cli/releases): release notes

## License

MIT
