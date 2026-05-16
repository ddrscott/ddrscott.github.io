---
title: "Vim Send Text"
date: 2017-04-10
created: 2017-04-10T00:00:00Z
type: blog
status: settled
tags: [vim]
publish: [ddrscott]
source: import
prompt: "Import from blog post: 2017/vim-send-text.markdown"
---

# Vim Send Text

<img src="https://raw.githubusercontent.com/ddrscott/vim-islime2/gh-pages/demo.gif" alt='Vim Send Text Demo' />

After pairing with some Sublime users, I noticed a neat feature. Or more
accurately, they were rubbing it in my face that their cute editor was better
than mine. The feature was [SendText](https://github.com/wch/SendText). Well, I
couldn't let Sublime users have all the fun, and apparently neither could a few
other people.

<!-- more -->

## History

There have been a few other implementations at this feature. These
implementations sent the text to a screen or tmux split. Since I don't use
either, I couldn't use them a la carte.

- https://github.com/vim-scripts/tslime.vim
- https://github.com/jpalardy/vim-slime
- https://github.com/ervandew/screen

This next implementation was good. It's only flaw, IMHO, was it's mappings and
naming. The naming "ISlime2" is impossible for me to type on the first try. The
mappings overlapped my existing mappings.
[ISlime2](https://github.com/matschaffer/vim-islime2) did all the hard work
AppleScript work and provides the Vim function to pass into the AppleScript.

Enter [vim-sendtext](https://github.com/ddrscott/vim-sendtext).
[vim-sendtext](https://github.com/ddrscott/vim-sendtext) is a fork of [ISlime2](https://github.com/matschaffer/vim-islime2).
My fork removes all the mappings, exposes useful internal functions, and adds
recommended mappings to the README.md.

## Recommended Mappings

```vim

" Send current line
nnoremap <silent> <Leader>i<CR> :SendTextCurrentLine<CR>

" Send in/around text object - operation pending
nnoremap <silent> <Leader>i :set opfunc=sendtext#iTermSendOperator<CR>g@

" Send visual selection
vnoremap <silent> <Leader>i :<C-u>call sendtext#iTermSendOperator(visualmode(), 1)<CR>

" Move to next line then send it
nnoremap <silent> <Leader>ij :SendTextNextLine<CR>

" Move to previous line then send it
nnoremap <silent> <Leader>ik :SendTextPreviousLine<CR>
```

## Vim Operator Pending

One of the main reasons to use Vim is Operator pending.  It's at the heart of
`vip`, `dip`, `ciw`, etc.
[vim-sendtext](https://github.com/ddrscott/vim-sendtext) provides an operator
pending function so we can logically do `{SEND}ap`, `{SEND}ip`, `{SEND}if`, etc.
The identical function works in visual mode to help build confidence in our text
object targets.

To read more about operator pending functions and how to create them try:
```vim
:h map-operator
```


## Conclusion

Hope [vim-sendtext](https://github.com/ddrscott/vim-sendtext) can remove some
feature envy from Sublime. Happy console hacking!
