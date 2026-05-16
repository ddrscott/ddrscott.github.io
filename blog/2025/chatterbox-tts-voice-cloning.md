---
title: "How to Say the Impossible with Voice Cloning"
date: 2025-01-06
created: 2025-01-06T00:00:00Z
type: blog
status: settled
tags: [ai, tts]
publish: [ddrscott]
source: import
description: "Make AI say tongue twisters for you"
image: /images/2025/cat-sweater.jpg
prompt: "Import from blog post: 2025/chatterbox-tts-voice-cloning.md"
---

# How to say the impossible: Voice Cloning

<img class="featured" src="/images/2025/cat-sweater.jpg" alt="Featured Banner" />

So I found myself with some free time and a dangerous combination: access to
[Chatterbox TTS](https://github.com/resemble-ai/chatterbox) and an irresistible urge to make AI say ridiculous things in my own voice. What could possibly go wrong?

## What is Chatterbox TTS?

Chatterbox TTS is a text-to-speech model that supports voice cloning - you feed it an audio sample of someone's voice, and it can generate new speech that sounds like that person. It's like having a digital ventriloquist and you are you're own dummy.

## The Setup

Getting started was surprisingly straightforward:

```python
from chatterbox.tts import ChatterboxTTS
import torch

# Automatically detect the best available device
if torch.cuda.is_available():
    device = "cuda"
elif torch.backends.mps.is_available():
    device = "mps"
else:
    device = "cpu"

model = ChatterboxTTS.from_pretrained(device=device)
```

The model loaded without complaint and immediately informed me it was using CUDA. Good start - my GPU was ready to make me sound like a robot trying to be me.

## The Voice Sample

I used a voice sample called `spierce-sample-2.wav` - presumably a recording of myself saying something coherent enough for the AI to learn from. The beauty of voice cloning is that you only need a short sample, maybe 5-10 seconds, and the model can extrapolate from there.

## The Torture Test: Tongue Twisters

Because I'm apparently 12 years old at heart, I decided the best way to test this voice cloning was with tongue twisters. If you're going to make an AI impersonate you, might as well make it suffer through the same verbal gymnastics that made you stumble in elementary school.

Here's what I fed it:

```python
text = """\
Near a ear, a nearer ear, a nearly eerie ear.

Roberta ran rings around the Roman ruins.

He threw three free throws.

A happy hippo hopped and hiccupped.

Toy boat. Toy boat. Toy boat.

A synonym for cinnamon is a cinnamon synonym.

One-one was a race horse. Two-two was one too. One-one won one race. Two-two won one too.
"""
```

## The Results

The generated audio was... well, it was definitely trying. The AI gamely attempted each tongue twister with the determination of someone who doesn't actually have a tongue to twist.

### Audio Samples

Here are the results from two different voice samples:

**Sample 2 (Original voice):**
<audio controls>
<source src="/images/2025/spierce-sample-2-twister.mp3" type="audio/mpeg">
Your browser does not support the audio tag.
</audio>

**Sample 3 (Refined voice):**
<audio controls>
<source src="/images/2025/spierce-sample-3-twister.mp3" type="audio/mpeg">
Your browser does not support the audio tag.
</audio>

### Observations

- **"Near a ear, a nearer ear"** - The AI handled the repetitive "ear" sounds reasonably well, though it had that slightly mechanical cadence that screams "I am definitely a robot"
- **"Toy boat" repetition** - This is where things got interesting. The AI seemed to understand that this was supposed to be rapid-fire, but the timing felt just a bit off
- **The race horse one** - Surprisingly coherent for such a complex tongue twister

The voice definitely sounded like it was trying to be me, with that uncanny valley quality where you think "that's almost right, but something's off." It's like hearing yourself on a recording, but if that recording was made by aliens who had only heard human speech through a tin can telephone.

## What's Actually Happening Here?

Voice cloning works by analyzing the acoustic characteristics of your voice sample - things like pitch patterns, formant frequencies, and speaking rhythm. The model then tries to apply these characteristics to new text. It's not perfect, but it's genuinely impressive how much personality it can capture from a short sample.

The tongue twisters were a good stress test because they require precise timing and articulation. Where a human would stumble and recover, the AI just... continues with robotic determination. There's something both admirable and slightly unsettling about that.

## The Verdict

Chatterbox TTS is surprisingly capable for voice cloning. While it's not going to fool anyone into thinking it's actually me speaking, it's close enough to be both impressive and mildly disturbing. The fact that I can generate this on my local GPU using CUDA makes it feel like we're living in the future - a slightly weird future where I can make digital copies of myself recite tongue twisters.

Would I use this for anything practical? Maybe. Could I use it to prank my friends? Absolutely. Will I resist the temptation to make it read my old blog posts in my own voice? Probably not.

The democratization of voice cloning technology is both exciting and terrifying. On one hand, it opens up creative possibilities for content creation and accessibility. On the other hand, well... let's just say we're living in interesting times.

Now if you'll excuse me, I need to go make my AI clone recite Shakespeare. For science, obviously.

---

*Have you experimented with voice cloning? Found any good use cases beyond making yourself say ridiculous things? Let me know in the comments - I promise it's actually me writing this, not my AI clone.*
