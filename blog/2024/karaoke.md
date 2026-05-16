---
title: "Karaoke"
date: 2024-09-19
created: 2024-09-19T00:00:00Z
type: blog
status: settled
tags: [life]
publish: [ddrscott]
source: import
description: "How to leverage technology to win at singing!"
image: /images/2024/karaoke-02.png
prompt: "Import from blog post: 2024/karaoke.md"
---

# How to Leverage Technology To Win At Singing

TL;DR - Karaoke!

My 10-year-old had a singing competition coming up in 2 weeks. He had two songs to perfect, and one was in Latin. His teacher provided an audio recording of herself performing to use as a reference when she wasn't around. The recording was good enough, but I thought we could do better. Karaoke!

Traditional karaoke machines perform brute force audio filtering by clipping middle frequencies, clipping identical frequencies found in the left and right channel, or removing the center channel, but that's not good enough for my son. I need AI magic!

> If it's worth doing, it's worth overdoing!
> - Me

## Get It Done!

1. **Get a recording with accompaniment of each song.** ✅ (His teacher sent this before the project started)
2. **Find an open-source project that uses AI to segment music files.** [Spleeter](https://github.com/deezer/spleeter) ✅
3. **Create a notebook in Google Colab to take the library out for a spin.** ✅
4. **Glue the separate wav files back together into a single MP3 file.** ✅
5. **Create an API for the project.** (Screenshot below. I can't publish it since it costs $$$) ✅ 
6. **Create a [static site audio player](https://ddrscott.github.io/prompt-games/singing) that allows my son to mix in or out vocals as needed.**  ✅
7. **PRACTICE!**

## Lessons Learned

The whole project stemmed from the thought: What can AI do for me? It taught me about the middle channel and filter
technique. It tried its best to implement some Python code using [librosa](https://librosa.org/doc/latest/index.html), but the output was never satisfactory. A simple web search discovered the [Spleeter project](https://github.com/deezer/spleeter), and ChatGPT was fairly good at implementing some snippets I could copy/paste.

I was impressed with its implementation of the JavaScript visualization in the audio player. It used [Flexbox](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout) predictably, but I had to interject to get the player on the bottom as a different component. The audio slider to mix the vocals and accompaniment was not trivial, and AI failed many, many times. I ultimately had to read the JS Audio API to figure out the nuances.

Overall, it was probably 80% AI-generated and 20% human-stitched and corrected. Time-wise, I think it would have been a wash regardless of AI. AI forced me to spend time troubleshooting unfamiliar code vs. traditionally reading unfamiliar docs.

- **Useful:** 5 of 5
- **Productizable:** 3 of 5
- **Bug-Free:** 2 of 5
- **Fun:** 5 of 5

## Screenshots

### Frontend for audio splitter
_I can't provide the URL since it costs $$$ to keep it alive_

<figure>
<img class="featured" src="/images/2024/karaoke-01.png" alt="Screenshot of Audio Splitter Site" />
<figcaption>Drag n' Drop MP3 or Wav or Whatever Audio File</figcaption>
</figure>

### Frontend for Karaoke Player
[Static Site](https://ddrscott.github.io/prompt-games/singing)

<figure>
<img class="featured" src="/images/2024/karaoke-02.png" alt="Screenshot of Audio Split Player" />
<figcaption>Add file to static file for playback.</figcaption>
</figure>

- No Lyrics
- No upload
- Everything is statically built off of my blog. Duct-tape and bubble gum till the bitter end.

## P.S.

So you wanna know how he did in his _first_ singing competition? Silver medalist 🥈. 99% Practice. 1% Technology.
