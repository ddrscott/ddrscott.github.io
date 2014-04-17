---
layout: post
title: "Octopress to the Rescue"
date: 2014-04-16 23:31:31 -0500
comments: true
categories: octopress
---

{% img featured /images/octopress_logo.png  227 227 'Octopress Logo' %}

After nearly a year without Posterous, I've finally got around to migrating to another system.
This time around it's a static blog builder: http://octopress.org/

<!-- more -->

Octopress is a wrapper around Jekyll which is a utility for creating a static blogging site. A blog that can be
hosted on anything that can server files: Apache, AWS, Dropbox, etc...

### Q: Why not use WordPress, Tumbler, Blogger?!?
Those tailor to non-developers and their editors are not the ones I use everyday, my IDE. Octopress lets me
write my articles the same way as I write code: plain text. It uses markdown or any other HTML generator I configure.

Static pages are easier for me to deploy when I have to switch hosting providers. Hopefully Github sticks around
for a while, but if they don't, I can rest assured I can have the article hosted some where else faster than DNS propagation.

``` ruby
puts "I can use code snippets"
# And they will be nicely formatted.
maybe_one_day do
  use(CodePen) or use(jsFiddle)
end
```

The initial theme I selected is https://github.com/sevenadrian/MediumFox. It's clean, simple and pretty much
what I would have *tried* to make if I had time. They seemed to have omitted some features from the classic theme, but
as with all Open Source projects it is easy to remedy.

Time to post to do my first deploy... then convert all the Posterous archives.