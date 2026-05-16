---
title: "Why AI Can't Make You a Beautiful Logo"
date: 2026-05-15
created: 2026-05-15T12:07:00Z
modified: 2026-05-15T12:07:00Z
type: blog
status: developing
tags: [ai, prompting, llm, design, communication]
publish: [ddrscott]
image: /images/2026/why-ai-cant-make-you-a-beautiful-logo.png
description: AI is a distillation of the internet. It cannot read your mind. The fastest way to better prompts is to strip subjective words and feed it objective context.
source: claude
prompt: "Convert May 15 prompting-AI transcript into a blog article"
---

**TL;DR** — AI is a distillation of the internet. It can't read your mind. The fastest way to get better results is to strip subjective words out of your prompts and feed it objective context instead. The same way you'd talk to a stranger you just met.

## "Make a beautiful logo"

Say you ask an AI: *"Make a beautiful logo that reflects the values of this website."*

That's it. You hit enter. You're trusting the model with a request that, in your brain, has a clear picture attached to it. Colors. Tone. The vibe of the site. Maybe a feeling you can't even put words to.

The AI has none of that.

It doesn't know if it should visit the website. It doesn't know what your conception of "beautiful" is. It doesn't even know if the domain name has any correlation to the content you actually care about. So it guesses. And then you're surprised when the guess is wrong.

## AI is a distillation of the internet

Here's the framing that fixes this for me: **AI is a distillation of the internet.** It's an extremely broad, general-purpose guesser. When you ask it something subjective, it's averaging across every opinion, style, and aesthetic on the open web and handing you back the centroid. There is essentially zero hope of that centroid matching what's in your head.

Try this thought experiment. Four people sit in a room. You say *"create a beautiful woman."* Each of those four people will draw a different person. Different hair, different build, different face, different everything. The word "beautiful" doesn't have a destination. It has four. Or four million.

Now do the same thing with *"blonde."* How blonde? Strawberry? Platinum? Dirty? You've narrowed it, but only a little.

The internet can't answer subjective questions because subjective questions don't have answers. They have preferences. And your preference is a thing only you can supply.

## The Google search rule still applies

If you typed *"beautiful woman"* into Google, you'd get a top page of results that are mostly stock photos and whatever the algorithm thinks is safe to surface. You'd scroll, drill in, refine — *"curly hair, round face, this height, this style"* — and slowly converge on what you actually wanted.

Same rule with AI. **Take every subjective word out.** Replace it with something measurable.

- ~~Beautiful~~ → high contrast, warm tones, geometric sans-serif
- ~~Modern~~ → flat color, no gradients, 8px rounded corners
- ~~Professional~~ → muted palette, generous whitespace, serif headings

This isn't because AI is dumb. It's because subjective words are coordinates without an origin. Objective words are coordinates with an origin. AI needs the origin.

## The trick: let AI teach you its language

Here's the move that changed how I prompt.

Don't pre-declare anything as good or bad. Don't say *"I like this style"* or *"this is the kind of thing I want."* That's all subjective and you're back to the same problem.

Instead: grab a reference image — a logo, a screenshot, a piece of art you respond to — drop it into the model, and say: **"Analyze this. Give me the words you think are appropriate for what I just gave you."**

The AI won't tell you if it's good or bad art. It'll do what a computer does. It'll tell you:

- The dominant color codes
- The tonal range (bright, dark, contrast ratios)
- The font family or family characteristics
- The composition (negative space, balance, weight)
- The mood vocabulary it associates with those properties

Now you have the AI's language for the thing you wanted. You can speak it back. *"Make me a logo that uses this palette, this kind of weight, this kind of negative space — but swap the serif for a geometric sans-serif and tighten the kerning by 5%."*

You've stopped guessing what AI knows. You've made AI tell you what it knows, and then you're working in that vocabulary.

## Prompting is about context

The whole thing reduces to two questions:

1. **Where are you starting?**
2. **Where do you need to get to?**

If you can answer both with specifics, AI fills in the middle. That's its job. That's what it's good at. The failures happen when you give it the destination ("beautiful logo") without the starting point, or the starting point without a destination.

Context isn't decoration on a prompt. It's the prompt.

## We do this with humans too

This isn't an AI quirk. It's a communication quirk that AI happens to amplify.

When I meet someone new — say I meet Timothy for the first time — we don't immediately get to business. We chat. We figure out what language we both speak. Where the common ground is. Whether we've got shared references — faith, family, profession, taste in music. Once we've calibrated, the actual conversation gets easier, faster, more precise.

AI is the same, just a touch more computery. Large language models understand English pretty well now, so you can be a little less robotic than you had to be three years ago. But you still need to be specific. You still need to calibrate. You still need to take out the subjective words and put in the objective ones.

## The whole article in one line

> Take subjective words out. Put objective things in. Let AI teach you its language before you try to speak it.

That's it. That's the diatribe. Go make better prompts.
