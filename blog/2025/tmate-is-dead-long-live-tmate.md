---
title: "tmate is Dead, Long Live tmate"
date: 2025-11-21
created: 2025-11-21T00:00:00Z
type: blog
status: settled
tags: [cli]
publish: [ddrscott]
source: import
description: "When your favorite terminal sharing tool stops working on your phone, it's time to find something new. A pragmatic guide to browser-based alternatives."
image: /images/2025/cat-phone-terminal.webp
prompt: "Import from blog post: 2025/tmate-is-dead-long-live-tmate.md"
---

# tmate is Dead, Long Live tmate

<img class="featured" src="/images/2025/cat-phone-terminal.webp" alt="A cat staring at a phone displaying terminal output" />

I've been a `tmate` loyalist for years. SSH into a shared tmux session? Chef's kiss. But here's the thing nobody tells you: try pulling that off on your phone while waiting at the DMV and you'll understand why I'm writing this post.

## The Problem

Picture this: I'm debugging a production issue from my kid's tennis match. I've got my phone, a spotty 4G connection, and a terminal sharing link from a colleague. The SSH client on my phone? It's... fine. The tiny keyboard? Torture. The inability to pinch-zoom on terminal output? Criminal.

Wouldn't it be great if I could just open a link in my phone's browser and see the terminal? You know, like how every other modern collaboration tool works?

## The Research Rabbit Hole

I did what any reasonable developer would do: I spent way too long researching alternatives. Here's what I found that actually works for Mac-to-phone terminal sharing via browser.

| Tool | Stars | Language | Last Release | Browser Access | Install | Key Feature |
|------|-------|----------|--------------|----------------|---------|-------------|
| [sshx] | 6,300+ | Rust | Feb 2025 | Shareable URLs | `brew install sshx` | E2E encrypted, infinite canvas |
| [ttyd] | 9,900+ | C | Mar 2024 | localhost:7681 | `brew install ttyd` | Fast, ZMODEM file transfer |
| [tty-share] | 857 | Go | Jan 2025 | Public URLs | `brew install tty-share` | Zero dependencies |
| [upterm] | 988 | Go | Nov 2025 | SSH over WebSocket | `brew install --cask upterm` | GitHub auth integration |
| [gotty] | 19,000+ | Go | Aug 2017 | localhost:8080 | `brew install gotty` | **Abandoned** |
| [wetty] | ~5,000 | TypeScript | Sep 2023 | SSH in browser | `npm -g i wetty` | Requires Node.js |
| [Warp] | 25,300+ | Rust | Weekly | Cloud-based | `brew install --cask warp` | AI Agent Mode (commercial) |

[sshx]: https://github.com/ekzhang/sshx
[ttyd]: https://github.com/tsl0922/ttyd
[tty-share]: https://github.com/nicusor/tty-share
[upterm]: https://github.com/owenthereal/upterm
[gotty]: https://github.com/yudai/gotty
[wetty]: https://github.com/butlerx/wetty
[Warp]: https://www.warp.dev/

### The Top 3 (That I'd Actually Use)

**1. sshx - The Winner (It's Rust!)**

```sh
brew install sshx
sshx
```

One command. Shareable URL. Done. No ngrok, no port forwarding, no fuss.

The URL has your encryption key embedded in the fragment (the part after `#`), so the server never sees your plaintext. End-to-end encryption without thinking about it.

The "infinite canvas" UI is wild - you can have multiple terminals floating around like some kind of terminal mood board. Live cursors show where other people are looking. There's even a chat. It's like Figma had a baby with tmux.

Why I chose it:
- **Written in Rust** - I try to support the Rust ecosystem when I can
- End-to-end encrypted (paranoid developers rejoice)
- One command to shareable URL
- Active development (Feb 2025 release)
- That infinite canvas thing is actually useful for pair programming

**2. ttyd - The Battle-Tested Alternative**

If you want something more established:

```sh
brew install ttyd
ttyd bash
```

Open `http://localhost:7681` in any browser. For remote access, pair it with ngrok:

```sh
ttyd -p 7681 bash
# In another terminal:
ngrok http 7681
```

Why it's solid:
- Written in C, so it's blazing fast
- Read-only by default (won't accidentally `rm -rf /` from your phone)
- ZMODEM file transfer if you're into that sort of thing
- 9,900+ GitHub stars means someone else debugged the hard stuff

**3. tty-share - The Lightweight One**

```sh
brew install tty-share
tty-share
```

Generates a public URL. Zero dependencies - it's a static Go binary. This is what you want on a Raspberry Pi or any resource-constrained environment.

Why I like it:
- Smallest footprint
- Works anywhere Go compiles
- January 2025 release, so it's not abandoned

### The One I'm Watching

**Warp Terminal** is doing interesting things with AI and collaboration, but it's commercial software and cloud-dependent. If your threat model allows it and you've got $20/month burning a hole in your pocket, it's worth a look. Their "Agent Mode" that accepts natural language commands is genuinely impressive. But I'm a POSIX curmudgeon, so YMMV.

### The Ones to Avoid

**gotty** - 19,000 stars but abandoned since 2017. There's an active fork by sorenisanerd, but why start with technical debt?

**wetty** - Last release September 2023. Requires Node.js. I have enough JavaScript in my life, thank you.

## My Actual Setup

Here's what I ended up with:

```sh
# ~/.zshrc or ~/.bashrc
alias share='sshx'
alias share-readonly='ttyd -R bash'
```

`sshx` for when I'm pair programming with someone I trust. `ttyd -R` for when I want to show my phone something without risking accidental keystrokes.

## The Security Bit

Look, sharing a terminal to your phone over the internet is inherently risky. Some ground rules:

1. **Read-only by default** - Both ttyd and tty-share support this
2. **Encrypted transport** - sshx does end-to-end, others use TLS
3. **Don't share production servers** - Obvious, but worth saying
4. **Kill the session when done** - `Ctrl+C` is your friend

## Conclusion

Browser-based terminal sharing has gotten good enough that I don't miss the SSH-based workflow on my phone. The tools are mature, actively maintained, and respect the Unix philosophy of doing one thing well.

**sshx is my pick.** It's Rust, it's encrypted, it's actively maintained, and it just works. I like supporting the Rust ecosystem when I can - the language attracts developers who care about correctness and performance, and it shows in the tooling.

If Rust isn't your thing, **ttyd** is the safe bet with years of battle-testing behind it.

What are you using? I'm curious if I missed anything good. Hit me up in the comments or on the socials.
