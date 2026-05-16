---
title: "Getting Rusty with Vim"
date: 2018-03-04
created: 2018-03-04T00:00:00Z
type: blog
status: settled
tags: [rust, vim]
publish: [ddrscott]
source: import
image: /images/rusty-featured.png
prompt: "Import from blog post: 2018/getting-rusty-with-vim.markdown"
---

# Getting Rusty with Vim
<img class="featured" src="/images/rusty-featured.png" alt="Vim Screenshot" />

After dabbing in Go and Crystal, I figured I'd give Rust a try. Of course I
used Vim along the way. Here are some notes I compiled after my first session.

<!-- more -->

## Vim Setup

There are 2 excellent Vim plugins which play nice with Rust. First is
https://github.com/rust-lang/rust.vim which provides:

> ... Rust file detection, syntax highlighting, formatting, Syntastic integration, and more.

It has nearly 1k stars, one of which is from me, and it's triple the stars of
`rust-mode` for Emacs.

The second plugin is https://github.com/racer-rust/vim-racer which provides omni-complete and jump to definition. Both features are good enough that I don't need to use ctags. I've in fact overridden several default Vim mappings with `vim-racer` implementations:

```vim
au FileType rust nmap <silent> <C-]> <Plug>(rust-def)
au FileType rust nmap <silent> <C-w><C-]> <Plug>(rust-def-vertical)
au FileType rust nmap <silent> <C-w>} <Plug>(rust-def-split)
au FileType rust nmap <silent> <C-k> <Plug>(rust-doc)
```

## Rust Experience

The featured image is an implementation of a number guessing game. The game is
from the Rust Tutorial Guide at
https://doc.rust-lang.org/book/first-edition/guessing-game.html. I followed the
guide sentence by sentence, line by line, and everything worked without
additional troubleshooting sessions. Good Job @rustlang! 

I massaged the code a little more to fool around and came up with the code in
the featured screen shot. The source is available in this [gist](https://gist.github.com/ddrscott/991a329b7f1c1f7682da5e4c24cdecc5). It's not the most exciting code I've
ever written, but possibly the most painless of the new languages I've tried.

When I came across some confusing language decisions. I posted a tweet about it:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Rust has clever tuple indexing, but square brackets would have been fine. What&#39;s wrong with `tuple[0]`? <a href="https://twitter.com/hashtag/rustlang?src=hash&amp;ref_src=twsrc%5Etfw">#rustlang</a> <a href="https://t.co/E0VY70zxuV">pic.twitter.com/E0VY70zxuV</a></p>&mdash; Scott Pierce (@_ddrscott_) <a href="https://twitter.com/_ddrscott_/status/969968042414366720?ref_src=twsrc%5Etfw">March 3, 2018</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

@rustlang responded quickly with insightful information. They're totally getting
the Raving Fan Award this weekend!

## Conclusion

Rust is worth pursing with or without Vim. The feedback from the compiler
and runtime errors is clear. The
[racer-rust](https://github.com/racer-rust/vim-racer) completion utility gives
all IDE super powers. And finally, I hear it's a pretty good language, too.  https://www.rust-lang.org

