---
title: "BS to the Black Hole"
date: 2016-04-13
created: 2016-04-13T00:00:00Z
type: blog
status: settled
tags: [vim]
publish: [ddrscott]
source: import
image: /images/blackhole_bs.png
prompt: "Import from blog post: 2016/bs-to-the-black-hole.markdown"
---

# BS to the Black Hole

![BS to Black Hole](../assets/2016/blackhole_bs.png)

First post in 2 years. Sorry to keep you waiting.

I've been playing with Vim again, more specifically NeoVim
https://neovim.io/, and this time I think it's going to stick.

## The Problem

Sometimes, I want to delete text without worrying about blowing away the `unnamed`
register. This can be done by prefixing a normal or visual delete with `"_`,
but that's an awkward dance for my pinky and ring finger. Go ahead, try it.
You'll feel like you're in junior high again.

<!-- more -->

## Solution #1

Setup a single key to do that `"_` thing for me. So my naive approach was to add
the following:

```vim
nnoremap <BS> "_
vnoremap <BS> "_
```

This was fine for 32.1 seconds of usability testing. It did the job, but what
cames after a `"_` was usually a `dw` or `db` operator. Ah oh, I said the "o"
word. That means I have to make a `opfunc`. (Who makes these rules?!?)

## Solution #2

So what is this operator going to let us do? How about `<BS>iw` or `<BS>ap` or
`v{motion around something you hate}<BS>`? If any of those seem awesome, here's
how to get in on the hot action!

```vim
" Add to your .vimrc or init.vim or vim.after or :e $MYVIMRC
func! BlackHoleDeleteOperator(type)
  if a:type ==# 'char'
    execute 'normal! `[v`]"_d'
  elseif a:type ==# 'line'
    execute 'normal! `[V`]"_d'
  else
    execute 'normal! `<' . a:type . '`>"_d'
  endif
endf

" Map to <BS> because it's under worked in Vim.
nnoremap <silent> <BS> <Esc>:set opfunc=BlackHoleDeleteOperator<CR>g@
vnoremap <silent> <BS> :<C-u>call BlackHoleDeleteOperator(visualmode())<CR>
```

## How Does it Work?
+ `opfunc` is best explained in Vim help. Use `:help opfunc` and follow the `<C-]>`
   until clarity is achieved.

+ `:help normal` - evaluates the following characters as if they were typed.

+ `:help marks` - page down a bit to get the list of automatic marks based on
   last positions of various changes, jumps, and actions.

+ http://learnvimscriptthehardway.stevelosh.com/chapters/33.html - seriously,
   this guy does a lot better explaining than me. Learn it the hard way, first,
   ask questions later.

## Closing

Thanks for getting this far. Do you have a better mapping for `<BS>`? Do you
have a more creative solution than typing `"_` to access the black hole
register? Let me know by commenting or share this post to some one who does.
