---
title: "Vim Toggle Movement: I Just Want to Go Home"
date: 2016-04-14
created: 2016-04-14T00:00:00Z
type: blog
status: settled
tags: [vim]
publish: [ddrscott]
source: import
image: /images/i_just_want_to_go_home.png
prompt: "Import from blog post: 2016/vim-toggle-movement.markdown"
---

# Vim Toggle Movement: I Just Want to Go Home
<img src="/images/i_just_want_to_go_home.png " alt='I just want to go home' />

I have a problem with the `^` key. I need its functionality, but its proximity is
too far for either of my stubby index fingers. No vimrc change can physically move it
closer to me, but I have found a way to move its funtionality to another a key.
A key which already knows how to go home. An alternate home. A home where my
heart isn't. Enough drama, what's the problem?!?

<!-- more -->
## The Problem

In my daily coding, I have a deep seeded need to go to the first non-blank
character of a line. The only key that Vim provides for that functionality is `^`,
the hardest key to reach from the home row. A much more comfortable key to reach
is `0`, but that shoots us past the first non-blank character all the way to
the left edge of the window. `<Home>` is the ugly step child of either option
since it's even harder to reach and takes us to the first column, too.

In case you don't believe me. Here's what the Vim document says:

```text
  0			To the first character of the line.  |exclusive|
        motion.

                *<Home>* *<kHome>*
  <Home>  To the first character of the line.  |exclusive|
        motion.  When moving up or down next, stay in same
        TEXT column (if possible).  Most other commands stay
        in the same SCREEN column.  <Home> works like "1|",
        which differs from "0" when the line starts with a
        <Tab>.

                *^*
  ^			To the first non-blank character of the line. |exclusive| motion.
```

Why can't I have a key that is easy to reach and takes me to the first
non-blank?!?

<img src="/images/venn_home_0.png " alt='venn diagram - home, caret, and 0' />

I could swap the functionality of `0` and `^`:

```
nnoremap 0 ^
nnoremap ^ 0
```

This still forces me to reach for `^` when I need to need to get to that left
edge. There must be a better way!

## The Solution

Let's give `0` some super toggling powers. When I hit it the first time, I want it be
be like `^`. If I hit it again, I want it to finish its travels and go to the
first column.

### Solution A

```vim
function! ToggleHomeZero()
  let pos = getpos('.')
  execute "normal! ^"
  if pos == getpos('.')
    execute "normal! 0"
  endif
endfunction

nnoremap 0 :call ToggleHome()<CR>
```

This gets us exactly to the center of Venn diagrams heart:

**Easy to reach + First non-blank character + First column = Rainbow Colored Unicorn!**

### Solution B

After enjoying staring at the function for a while, I realized we could add
super toggling powers to other movements. Lets extract the `normal` commands
into arguments and share the love with other keys!

```vim
function! ToggleMovement(firstOp, thenOp)
  let pos = getpos('.')
  execute "normal! " . a:firstOp
  if pos == getpos('.')
    execute "normal! " . a:thenOp
  endif
endfunction

" The original carat 0 swap
nnoremap <silent> 0 :call ToggleMovement('^', '0')<CR>

" How about ; and ,
nnoremap <silent> ; :call ToggleMovement(';', ',')<CR>
nnoremap <silent> , :call ToggleMovement(',', ';')<CR>

" How about H and L
nnoremap <silent> H :call ToggleMovement('H', 'L')<CR>
nnoremap <silent> L :call ToggleMovement('L', 'H')<CR>

" How about G and gg
nnoremap <silent> G :call ToggleMovement('G', 'gg')<CR>
nnoremap <silent> gg :call ToggleMovement('gg', 'G')<CR>
```

## Conclusion

`ToggleMovement` is the gift that keeps on giving!

What other movement can we add to the list?
Let me know in the comments below.
