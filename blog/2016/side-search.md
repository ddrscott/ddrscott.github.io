---
title: "Vim Side Search: Making Search Fun Again"
date: 2016-05-27
created: 2016-05-27T00:00:00Z
type: blog
status: settled
tags: [vim]
publish: [ddrscott]
source: import
image: /images/vim_ag_unicorn.png
prompt: "Import from blog post: 2016/side-search.markdown"
---

# Vim Side Search: Making Search Fun Again
<img src="/images/vim_ag_unicorn.png" alt='Vim + Ag = Unicorn' />

The `quickfix` feature is nice, but it doesn't give enough context around the
search term that leads to use `ag` from terminal and switch back and forth
between programs. I do this search dance every day and I've had it! There must
be better way!

<!-- more -->

## Problem
<img src="/images/side-search-a.png" alt='Quickfix for help' />
Look at the `quickfix` window above. It spends most of its space showing the file name
of the hit, then the remainder is spent on text around it. In projects using 
[Rails Engines](http://guides.rubyonrails.org/engines.html) with deeply nested
directory structures, this often leaves me with just a bunch of paths in the `quickfix`.


## Solution A - The Unix Way

Some may argue Vim isn't suppose to do search. Vim rightly delegates to the
[Unix philosophy](http://www.catb.org/esr/writings/taoup/html/ch01s06.html) by
allowing an external program do its searching. Let's try that for this
solution using `grep`, `ack`, and `ag`.

<img src="/images/side-search-compare.png" alt='grep vs ack vs ag' />

We've run the 3 separate programs (normally, I would only use `ag`) then
browse the results to see if there's an interesting file. At this point I start
using my handy-dandy mouse to scroll around, precisely highlight the path of
interest, copy, and type `vim <Paste>`. Intuitive? Yes. Fast? No!

Maybe I should use `tmux` or `screen` so I don't need to mouse around, but
trying to select a path is still pretty slow for me and requires more cognitive
load than I have patience for. After all, I'm trying to concentrate on a
refactor or something, not how to open a bunch of files. Should I practice more?
Yes. Will I? No!

We're going to use `ag` from now on, since it's faster than `ack`, and has
prettier output than `grep`. I really really really tried to get `grep` to
output for humans, but couldn't figure it out.


## Solution B - Vim without Quickfix

Let Vim do some work for us.

```
vim `ag --ignore=\*.{css,scss} -l help` +'/help'
```

What's that?!? Open Vim passing the result of `ag` command. `ag` is run with
some file exclusions, `-l` only file names, and `help` is the search term.
`+'/help'` tells Vim to immediately start searching for 'help'.

After all that, Vim should have started with a bunch of buffers. View them with
`:ls`. Take notice of the buffer numbers to see how many files were found. Use
`n` and `N` to jump through search matches in the file. Use `:bn` to go to the
next buffer and start hitting `n` again to cycle through the changes. If the
number of files is small enough, you may be able to use `:ball` to open every
buffer in its own window.

Thats a lot of work to jump through changes. Good thing the `quickfix` exists.

## Solution C - Quickfix

This is here for posterity. `quickfix` DOES make cycling through changes easier
than Solution B, but as I stated in the intro, it doesn't give the context that
we want.

[Thoughtbot has a pretty good article](https://robots.thoughtbot.com/faster-grepping-in-vim)
about how to setup Vim to use `ag`. Once you do that, you can `:grep help` to
get the following output:

<img src="/images/side-search-a.png" alt='Quickfix for help' />

Use `:cnext`, `:cprev`, `:cfirst`, `:clast` to go to next, previous, first, and
last `quickfix` result respectively. Map those to keys to make it easier to
navigate.

```
nnoremap [q :cprev<CR>
nnoremap ]q :cnext<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
```

Get more help about `quickfix` using `:help quickfix`. Cry after realizing
even `:help quickfix` can't show more context. I'll be here when you're done.

## Solution D - Side Search Plugin

So how do we get the best of both worlds? How do we enter the land of a thousand
wives/husbands? How do we get `ag` output and quick navigation? For me, it
was writing a plugin in. For you it's using it. https://github.com/ddrscott/vim-side-search

After installing the plugin using your favorite package manager, you'll have
access to the following functionality:

<img src="/images/side-search-demo-b.gif" alt='Side Search Demo' />

Things to notice:

  - `ag` output is in a buffer with additional syntax highlighting!
  - `n` and `N` used to jump to matches. Regular Vim navigation works, too!
  - `<CR>` and `<C-w><CR>` used to open change and jump to change!
  - Number of matches shown in the buffer name!
  - I use too many exclamation points!!!

The plugin's `README` has more details.

## Closing

I've been using this plugin ever since its inception and don't know where I'd
be without it. It gets some inspiration from [fugitive's](https://github.com/tpope/vim-fugitive)
`:Gstatus` mode/buffer, and I wish there were more plugins that added
functionality from `stdout` instead of transforming it into a different format. Unix
tools makers spend a lot of time thinking about the output. Let's use it to our
advantage.

I've learn a lot creating this plugin and plan to write about it in a future post.
Do you love it or hate it? Have more ideas for Side Search? Please let me know what you
think of it. Have more ideas or issues for Side Search? Hit me up on [Github](https://github.com/ddrscott/vim-side-search).

### References

  - [The Silver Searcher](https://github.com/ggreer/the_silver_searcher) by Geoff Greer
  - `man ag`
  - `man grep`
  - `man tmux`
  - `man screen`
  - `:help quickfix`
  - [Faster Grepping in Vim](https://robots.thoughtbot.com/faster-grepping-in-vim) by Thoughtbot
  - [The number 12](https://www.google.com/search?q=the+number+12)

### In The News

  - [Hacker News](https://news.ycombinator.com/item?id=11787085)
  - [Reddit](https://www.reddit.com/r/vim/comments/4lbdur/vim_side_search_plugin_making_search_fun_again/)
