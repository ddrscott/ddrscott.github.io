---
title: "RingLite: A Virtual Ring Light That Doesn't Exist"
date: 2025-11-21
created: 2025-11-21T00:00:00Z
type: blog
status: settled
tags: [cli]
publish: [ddrscott]
source: import
description: "Introducing RingLite - a virtual ring light for video recording that's invisible to screen recorders. Built with Tauri, it floats above your content so you can see your script while looking well-lit."
image: /images/2025/ringlite-screenshot.jpg
prompt: "Import from blog post: 2025/ringlite-virtual-ring-light.md"
---

# RingLite: A Virtual Ring Light That Doesn't Exist

<img class="featured" src="/images/2025/ringlite-screenshot.jpg" alt="RingLite virtual ring light floating on screen" />

## The Problem With Real Ring Lights

If you've ever done video recording or live streaming, you know the struggle. You set up your fancy ring light, position it *just* right, and then realize you can't see your notes behind it. Or worse, it's sitting off to the side casting weird shadows that make you look like a villain in a budget horror film.

Physical ring lights are great at one thing: being in the way.

Wouldn't it be great if you could have a ring light that:

1. Floats right where you need it
2. Lets you see your script/notes through the center
3. Doesn't show up in your screen recordings

Well, I got annoyed enough to build exactly that.

## Introducing RingLite

RingLite is a virtual ring light that lives on your screen. It's a simple glowing white ring that you can drag anywhere, resize to fit your face, and - here's the magic part - **it's completely invisible to screen recorders**.

That last bit is the whole point. You can position it right over your webcam preview, read your notes behind it, and your audience never sees it. It's like having a teleprompter and ring light in one invisible package.

## How Does the Invisibility Work?

Both macOS and Windows have APIs that let you exclude windows from screen capture. Most apps don't use them, but they're perfect for this use case.

On macOS, it's a matter of telling the window "don't share yourself":

```rust
// NSWindowSharingType.none
let _: () = msg_send![ns_window, setSharingType: 0];
```

On Windows, there's a similar API:

```rust
SetWindowDisplayAffinity(hwnd, WDA_EXCLUDEFROMCAPTURE);
```

The window still exists, you can still see it, but OBS, Zoom, and every other screen recorder just... don't. It's like the ring light has an invisibility cloak.

## The Controls

I kept it simple:

| Action | Control |
|--------|---------|
| Move | Drag anywhere |
| Resize | Scroll wheel or `+`/`-` |
| Nudge | Arrow keys |
| Help | `H` |
| Quit | `Esc` |

The ring remembers its size between sessions because nobody wants to resize their ring light every single time.

## Built With Tauri

I went with [Tauri](https://tauri.app/) for this because:

1. Cross-platform (macOS and Windows) with native performance
2. Tiny binary size (no Electron bloat)
3. Rust backend means easy access to native APIs for the screen capture exclusion

The whole UI is just HTML/CSS/JS - a glowing ring with a box-shadow. The glow effect is achieved with layered shadows:

```css
#ring {
  border: var(--ring-thickness, 40px) solid white;
  box-shadow:
    0 0 60px 20px rgba(255, 255, 255, 0.3),
    inset 0 0 60px 20px rgba(255, 255, 255, 0.1);
}
```

Nothing fancy, but it looks the part.

## Get It

Download from [GitHub Releases](https://github.com/ddrscott/ringlite/releases).

**macOS users**: Right-click and choose "Open" the first time to bypass Gatekeeper. Apple doesn't trust me, and honestly, that's fair.

## The Takeaway

Sometimes the best tools are the ones that get out of your way - or in this case, stay in your way while pretending they don't exist.

If you're recording videos or doing live streams and fighting with your ring light placement, give RingLite a try. At worst, you've got a free floating glow ring. At best, you'll wonder why this wasn't a thing sooner.

---

Have questions or want to see other "invisible overlay" tools? Let me know in the comments.
