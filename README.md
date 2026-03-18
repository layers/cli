# Layers CLI

**Turn your code into customers.**

Layers CLI connects your app to the [Layers](https://layers.com) growth engine — automated content creation, ad management, and attribution tracking — all from your terminal. Your code never leaves your machine.

```bash
$ layers get-users

  Framework     React Native (Expo)
  Auth          Firebase Auth
  Payments      RevenueCat

  Connect Instagram? [Y/n] ✓ @yourapp (1,204 followers)
  Connect Meta Ads?  [Y/n] ✓ Connected

  Launching growth plan...
  ✓ 5 content pieces generating
  ✓ Meta ad campaign created ($20/day)
  ✓ Attribution SDK ready

  You're live. Keep coding — I've got the marketing.
```

## What Layers Does For You

- **Content** — Generates short-form video and social posts tailored to your app
- **Ads** — Creates and optimizes Meta + TikTok campaigns automatically
- **Attribution** — Tracks exactly which content and ads drive installs
- **Daily Digest** — Texts you every morning with your numbers
- **Auto-Optimization** — Pauses underperformers, shifts budget to what works

All without you opening Ads Manager, creating a single post, or configuring a pixel.

## Install

**macOS:**
```bash
brew install layers/tap/layers
```

**Linux / macOS:**
```bash
curl -fsSL https://layers.com/install.sh | sh
```

**Windows:**
```powershell
scoop bucket add layers https://github.com/layers/scoop-bucket
scoop install layers
```

**Direct download:** [GitHub Releases](https://github.com/layers/cli/releases)

## Quick Start

```bash
# 1. Sign in (opens browser, one click)
layers login

# 2. Run the guided setup in your project directory
cd your-app
layers setup

# 3. That's it. Check back tomorrow.
layers status
```

The setup wizard walks you through everything: connects your social accounts, sets up ad campaigns, instruments your SDK, and launches your first growth campaign. About 3 minutes.

## The Daily Workflow

Once you're set up, Layers runs on autopilot. Your daily touchpoint is ~5 minutes:

```bash
# Morning: check your numbers
layers status

# Review content Layers generated for you
layers review

# See what Elle (your growth AI) recommends
layers digest
```

Layers auto-generates content based on your app, runs your ad campaigns, and optimizes spend — all while you write code. When you ship a new feature, Layers detects it and creates marketing content automatically.

## Works With Your AI Coding Tool

Layers integrates with Claude Code, Cursor, Windsurf, and Codex via MCP:

```bash
layers setup-editor
```

Then in your editor:
```
> @layers how are my ads doing?
> @layers generate content about the feature I just shipped
> @layers pause ads for the weekend
```

## Privacy First

Your code **never leaves your machine**. The CLI analyzes your project locally (framework detection, dependency scanning) and sends only structured metadata to Layers — framework name, bundle ID, platform type. No source code, no file contents, no environment variables.

[Read the full privacy model](https://layers.com/privacy)

## All Commands

### Setup & Auth
| Command | What it does |
|---------|-------------|
| `layers login` | Sign in via browser |
| `layers logout` | Sign out |
| `layers setup` | Guided onboarding (the main event) |
| `layers get-users` | Same as setup |
| `layers link` | Connect to an existing Layers project |
| `layers open` | Open dashboard in browser |

### Daily Usage
| Command | What it does |
|---------|-------------|
| `layers status` | Performance dashboard with sparklines |
| `layers review` | Approve or edit generated content |
| `layers budget` | View or adjust ad spend |
| `layers digest` | Daily performance summary |
| `layers doctor` | Check everything is configured correctly |

### SDK & Analysis
| Command | What it does |
|---------|-------------|
| `layers analyze` | Scan your codebase locally |
| `layers connect` | Connect social or ad accounts |
| `layers sdk install` | Generate SDK instrumentation spec |
| `layers sdk validate` | Verify SDK is integrated correctly |
| `layers setup-editor` | Install MCP for AI coding tools |

### Project Management
| Command | What it does |
|---------|-------------|
| `layers orgs list` | List your organizations |
| `layers projects list` | List your projects |
| `layers whoami` | Show current user |
| `layers update` | Update CLI to latest version |
| `layers version` | Show version info |

## Troubleshooting

**Can't sign in?** Make sure ports 54321-54323 aren't in use. The CLI opens your browser and listens for the OAuth callback on localhost.

**No project found?** Run `layers setup` in your project directory, or `layers link` to connect to an existing project.

**Keychain errors on Linux?** Install `gnome-keyring` or `kwallet`. Falls back to encrypted file storage at `~/.config/layers/`.

**Need help?** `layers doctor` checks your entire setup and tells you what's wrong.

## Links

- [Layers](https://layers.com) — Main site
- [Dashboard](https://app.layers.com) — Web dashboard
- [Documentation](https://docs.layers.com) — Full docs
- [Changelog](https://github.com/layers/cli/releases) — Release notes

## License

MIT
