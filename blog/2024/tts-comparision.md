---
title: "Karaoke"
date: 2024-09-24
created: 2024-09-24T00:00:00Z
type: blog
status: settled
tags: [life]
publish: [ddrscott]
source: import
description: "What it's like when robots campaign for your Site Reliability position"
image: /images/2024/tts-robots.jpg
prompt: "Import from blog post: 2024/tts-comparision.md"
---

# Robots Campaigning for a Site Reliability position

<img class="featured" src="/images/2024/tts-robots.jpg" alt="Featured Banner" />

I've been doing a lot of comparisons between Text to Speech (TTS) engines recently and run into a this post
from [Julien Bicknell](https://www.linkedin.com/in/juliensydney) who had ChatGPT "write a job ad in the style of Donald
Trump". I couldn't resist passing the generated script through to the Text to Speech engines in front of me.

**WARNING**: This is NOT a comprehensive analysis.
I'm simply posting these recordings so I don't forget about them, and can listen to them in the future for a laugh. If someone wants a thorough analysis make me an offer. In the meantime, enjoy the robots trying to get an SRE job.

## Audio Outputs from Various Vendors

<table>
<tr>
    <td>
    <a href="https://platform.openai.com/docs/guides/text-to-speech/nova" target="_blank"><b>Open AI - Nova</b></a>
    </td>
    <td>
    <audio controls>
    <source src="https://cdn.dataturd.com/audio/tts-compare/Nova_tts-1_1x_2024-09-24T14_51_12-149Z.mp3" type="audio/mpeg">
    Your browser does not support the audio tag.
    </audio>
    </td>
</tr>
<tr>
    <td>
    <a href="https://console.cloud.google.com/speech/text-to-speech;locale=en-US;voice=en-US-Casual-K;encoding=LINEAR16;speed=1;location=global" target="_blank"><b>Google Vertex AI - Casual K</b></a>
    </td>
    <td>
    <audio controls>
    <source src="https://cdn.dataturd.com/audio/tts-compare/vertext-ai-en-us-casual-K-beta.mp3" type="audio/mpeg">
    Your browser does not support the audio tag.
    </audio>
    </td>
</tr>
<tr>
    <td>
    <a href="https://console.cloud.google.com/speech/text-to-speech;locale=en-US;voice=en-US-Journey-O;encoding=LINEAR16;speed=1;location=global" target="_blank"><b>Google Vertex AI - Journey-O</b></a>
    </td>
    <td>
    <audio controls>
    <source src="https://cdn.dataturd.com/audio/tts-compare/vertext-ai-en-us-journey-O-preview.mp3" type="audio/mpeg">
    Your browser does not support the audio tag.
    </audio>
    </td>
</tr>
<tr>
    <td>
    <a href="https://play.ht" target="_blank"><b>Play.HT - Play v3</b></a>
    </td>
    <td>
    <audio controls>
    <source src="https://cdn.dataturd.com/audio/tts-compare/play-ht-v3.mp3" type="audio/mpeg">
    Your browser does not support the audio tag.
    </audio>
    </td>
</tr>
<tr>
    <td>
    <a href="https://copilot.microsoft.com/" target="_blank"><b>Microsoft Copilot</b></a>
    </td>
    <td>
    <audio controls>
    <source src="https://cdn.dataturd.com/audio/tts-compare/ms-copilot-trimmed.mp3" type="audio/mpeg">
    Your browser does not support the audio tag.
    </audio>
    </td>
</tr>

</table>

## Conclusion

They all feel robotic to me, but Open AI feels the most natural at the moment. I'm sure I could use Speech Synthesis
Markup Language (SSML) tags to improve it a bit from Vertex AI, but that would require me to add those tags to voice
script or prompt ChatGPT to generate it with SSML tags.


## Original Script

[LinkedIn Post](https://www.linkedin.com/posts/juliensydney_makeadvertsgreatagain-activity-7243775950448947200-xzYH)

<img class="featured" src="/images/2024/tts-trump.png" alt="Featured Banner" />

> Listen, folks, I’ve talked to many, many people, and they all agree – we need the BEST Site Reliability Engineers. 
> 
> This is going to be the most incredible team, and we’re going to win. No one knows more about uptime and reliability than we do – nobody.
> 
> What you’ll do: We’re talking cloud infrastructures, folks – AWS, Azure, GCP – you know it better than anyone. Automation? We’re going to automate like never before. Monitoring? It’s going to be beautiful. We’re going to watch everything, 24/7, and it’s going to work. Some people don’t know how to do this, but we do.
> 
> You’ll need:
> Cloud platforms experience. AWS, Azure, Google Cloud – we’re the best with all of them.
> Automation skills. We’re talking Ansible, Terraform, Python – and folks, we automate more than anyone, believe me.
> Kubernetes expertise – everyone’s talking about it, folks. And we’re doing more with it than anyone.
> Monitoring tools like Prometheus and Grafana. We see everything – everything.
> CI/CD pipelines? You build them, you run them, you win with them.
> 
> Some people say it can’t be done. But let me tell you something – it can. And we’re going to do it better than anyone ever has. We’re going to make reliability so good, you’ll get tired of being reliable!
> 
> Here’s the deal:
> Tremendous salary – no one pays better, believe me.
> Amazing benefits. You’ll say, “Mr. SRE Manager, I’ve never seen benefits like these before!”.
> Work from the best places – remote, flexible, we’ve got it all. No one works better.
> 
> Folks, this is the kind of role where people are talking about it. 
> 
> I was at a debate the other day, and let me tell you, everyone’s talking about how important it is to keep systems running. We’re going to bring back uptime. We’re going to bring back stability. And we're going to make systems so reliable, you’ll get tired of being reliable. 
> 
> Believe me!
> 
