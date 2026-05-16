---
title: "Browser Agent - Claude Code Plugin for Playwright"
date: 2026-01-06
created: 2026-01-06T00:00:00Z
type: blog
status: settled
tags: [claude-code]
publish: [ddrscott]
source: import
description: "Stop fighting your browser automation. A context-friendly Playwright plugin for Claude Code."
image: /images/2026/browser-agent-meme.jpg
prompt: "Import from blog post: 2026/browser-agent-plugin.md"
---

# Browser Agent: Claude Code Meets Playwright

<img class="featured" src="/images/2026/browser-agent-meme.jpg" alt="Micro manage my browser like a boss" />

**Stop fighting your browser automation. Start controlling it.**

I built [browser-agent](https://github.com/ddrscott/wiz-marketplace) because existing solutions frustrated me:

- **Microsoft's [playwright-mcp](https://github.com/microsoft/playwright-mcp)** dumps ~16k tokens of accessibility tree on every call
- **Other Playwright skills** open and close the browser constantly, losing your session

I wanted something that felt natural—where I could tell Claude to browse Amazon, take over manually to poke around, then hand control back without losing my session or burning context.

## The Solution

A persistent Chrome process that survives script execution. Claude connects, does work, disconnects. The browser stays open.

```
┌─────────────────┐          ┌──────────────────────┐
│  /browser cmd   │──────────│  Chrome (persistent) │
│  or Task agent  │   CDP    │  --remote-debugging  │
└─────────────────┘          └──────────────────────┘
        │                              ▲
        ▼                              │
   script runs                    stays open
   then disconnects              user can interact
```

## Quick Demo

```bash
# Navigate
/browser go to amazon.com

# Search
/browser search for VR headsets

# Extract info
/browser what's the top pick on this page?

# Take over manually, browse around...

# Hand back to Claude
/browser click Add to Cart
```

The browser window stays visible. You can interact with it anytime. Claude reconnects to the same session—cookies, logins, everything persists.

## Why It Works

| Problem | Old Way | Browser Agent |
|---------|---------|---------------|
| Context bloat | 16k tokens per call | Only script results |
| Browser lifecycle | Opens/closes constantly | Persistent via CDP |
| User handoff | Locked out during automation | Take over anytime |
| API limitations | Predefined commands only | Full Playwright API |

Claude writes custom Python scripts for each task using the complete Playwright API. No artificial limits.

## Architecture

The plugin uses Claude Code's native patterns:

- **Agent** (`agents/browser.md`) - System prompt with Playwright API reference
- **Skill** (`skills/browser.md`) - Delegation patterns for the main agent
- **Command** (`commands/browser.md`) - The `/browser` slash command
- **Script** (`scripts/browser.py`) - Thin executor managing Chrome lifecycle

The script is intentionally minimal—it handles the boring infrastructure (starting Chrome, CDP connection, PID tracking) so Claude's generated scripts stay focused on the actual task.

## Get It

```bash
# Clone the marketplace
git clone https://github.com/ddrscott/wiz-marketplace

# Install the plugin
claude plugin install wiz-marketplace/browser-agent
```

Prerequisites: Chrome, Python 3.11+, [uv](https://docs.astral.sh/uv/)

## What's Next

This is part of [wiz-marketplace](https://github.com/ddrscott/wiz-marketplace), a collection of Claude Code plugins built with context efficiency in mind. More plugins coming.

If you build something cool with it, let me know.
