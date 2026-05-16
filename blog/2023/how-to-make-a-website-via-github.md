---
title: "How to Make a Website from scratch in 7:59 seconds with Github"
date: 2023-03-15
created: 2023-03-15T00:00:00Z
type: blog
status: settled
tags: [life]
publish: [ddrscott]
source: import
description: "Wordpress? Squarespace? Wix? Not today. Those are great products for hosting articles and marketing, but you want to make an application. You want to make something the old-fashioned way. You want to know what's under the hood, and you want to make it easy for others to help you along the way."
image: /images/2023/github/github-featured-800x.png
prompt: "Import from blog post: 2023/how-to-make-a-website-via-github.md"
---

# How to Make a Website from scratch in 7:59 seconds with Github

Wordpress? Squarespace? Wix? Not today. Those are great products for hosting articles and marketing, but you want to make an application. You want to make something the old-fashioned way. You want to know what's under the hood, and you want to make it easy for others to help you along the way.

<img class="featured" src="/images/2023/github/github-featured-800x.png" alt="Featured Banner" />

**TL;DR** - The goal is to ~understand how~ make a website. Enter Github and Codespaces!

## Steps

### Create a Github Account
I made one for my friend: TheChickenCow.

<div style="position: relative; overflow: hidden; width: 100%; padding-top: 56.25%;">
<iframe  style=" position: absolute; top: 0; left: 0; bottom: 0; right: 0; width: 100%; height: 100%;"
        src="https://www.youtube.com/embed/iCdrckv937Y"
        title="YouTube video player"
        frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
</div>

### Start a Codespaces

Use `Codespaces` instead of `Create Respository`.

<img src="/images/2023/github/step2-codespaces-800x.png" alt="use codespaces" />

We'll eventually use Codespaces to push to the repository. Otherwise, it'll take more steps to import the repository into Codespaces. Trust us!


### Create the Content for the Website

<img src="/images/2023/github/step3-create-files-800x.png" alt="create files" />

#### docs/index.html

This is the primary content of the webpage.

```html
<!doctype html>
<html lang="en" class="no-js">
    <head>

        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <link rel="manifest" href="manifest.json">

        <link rel="canonical" href="https://thechickencow.github.com/dune-scroller">

        <title>Dune by Frank Herbert 1965</title>

        <meta property="og:title" content="Dune by Frank Herbert">
        <meta property="og:description" content="A young man's journey through political conflict on a desert planet that holds the key to the universe's most valuable substance">
        <meta property="og:image" content="https://upload.wikimedia.org/wikipedia/en/d/de/Dune-Frank_Herbert_%281965%29_First_edition.jpg">
        <meta property="og:url" content="https://thechickencow.github.com/dune-scroller">

        <script src="app.js" async></script>
        <link rel="stylesheet" href="app.css">
    </head>
    <body dir="ltr">
        <h1>
            <img src='https://upload.wikimedia.org/wikipedia/en/d/de/Dune-Frank_Herbert_%281965%29_First_edition.jpg' alt="Book Cover"/>
        </h1>
        <div class="content"></div>
    </body>
</html>
```

#### docs/app.css

This provides the styling and coloring.

```css
:root {
    /* https://paletton.com/#uid=30A0u0k4ftn0mRD1TBP7no+bil4 */
    --base-color: #EADBCB;
    --text-color: #4F5573;
    --highlight-color: #70927C;
}

body {
    background-color: var(--base-color);
    color: var(--text-color);
    padding: 0 10vw;
    margin: 0;
    font-family: serif;
    font-size: 18px;
    border-left: 10px solid var(--highlight-color);
}

h1 {
    margin-top: 0;
}

.content {
    white-space: pre-line;
    line-height: 2;
    text-align: justify;
}

```

#### docs/app.js

This defines the behavior which fetches the book contents from a different Github page to display it on our website.
This is for demonstration purposes only. Do this at your own risk.

```javascript
const book_url = 'https://raw.githubusercontent.com/ganesh-k13/shell/master/test_search/www.glozman.com/TextPages/Frank%20Herbert%20-%20Dune.txt';

fetch(book_url).then(function (response) {
    return response.text();
}).then(function (html) {
    document.querySelector('.content').innerHTML = html.replace(/\n\n/g, '<br/>');
}).catch(function (err) {
    console.warn('Something went wrong.', err);
});
```

#### README.md

```markdown
# Dune Scroller

     _____________________
    < Yep. We went there. >
     ---------------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||

Read Dune by Frank Herbert via scrolling the whole freaking thing.

## Future Features

As an exercise to do at home:

- Pick up were you left off, because no one can finish this book in a single sitting.
- Auto-scroll based on momentum of initial drag scroll.
- Change font size.

## Thanks

- [ganesh-k13](https://github.com/ganesh-k13/shell/blob/master/test_search/www.glozman.com/TextPages/Frank%20Herbert%20-%20Dune.txt) for the Dune text
- [Wikipedia](https://en.wikipedia.org/wiki/Dune_(novel\)) for the book cover
```

### Publish to Github

1. Select the Branch Tab on the far left side.
2. Select `Publish to Github`
3. Rename `codespaces-blank` to `dune-scroller`
4. Select Publish to Github public (not private)

<img src="/images/2023/github/step4-publish-to-github-800x.png" alt="Publish to Github" />

All files in the project will get automatically selected and hit `OK` to confirm the upload.

### Open on Github

Notice the notifications at the bottom of Codespaces. It will show the repository has been published to Github.
Select `Open on Github` to see the source code.

<img src="/images/2023/github/step5-open-on-github-800x.png" alt="Open on Github" />

### Publish the Final Site

1. Select the `Settings` tab near the top.
2. Select the `Pages` tab in the left sidebar.
3. In the Branch section, choose `main`
4. Next to it, choose `/docs`
5. Finally, click `Save`

<img src="/images/2023/github/step6-publish-pages-800x.png" alt="Publish Pages" />

The publish will kick off a deployment Action.

### Wait about 2-minute

The initial deployment of the site take about 2 minutes.

Actions are observable in the top `Actions` tab.
1. Select `Actions` from the tab tab.
2. Select `pages build and deployment`

<img src="/images/2023/github/step7-wait-for-deployment.png" alt="Wait" />

### Get the Link

When the deployment is finished, the `deploy` step
will reveal the final website link that you can share with friends
and family or the rest of the Internet.

<img src="/images/2023/github/step8-website-link-800x.png" alt="Get the Link" />

https://ddrscott.github.io/dune-scroller/ 


## Conclusion

We hope this step by step tutorial helped give you a start on your web development journey. We know this probably gave you more questions than answers, but the goal was to get you started and have a site at the end.

To learn more about Codespaces try their documentation: https://docs.github.com/en/codespaces


### Languages Used

- html
- css
- javascript

Learn about all 3 from https://www.w3schools.com/default.asp


## Connect

Let us know what you're working on or publish or stuck on in the comments below. Happy coding!
