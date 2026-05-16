---
title: "PSA: Vim Modulo '%' Returns Negative Numbers!"
date: 2016-05-28
created: 2016-05-28T00:00:00Z
type: blog
status: settled
tags: [vim]
publish: [ddrscott]
source: import
image: /images/einstein_mod.jpg
prompt: "Import from blog post: 2016/negative-modulo.markdown"
---

# PSA: Vim Modulo '%' Returns Negative Numbers!
<img src="/images/einstein_mod.jpg" alt='-10 % 3 != -1' />

Surprise! Vim has the same modulo bug as Javascript. Some say it's not a bug,
but if Ruby and Google Calculator is wrong, I don't want to be right.

<!-- more -->

* Vim, `:echo -10 % 3` returns `-1`
* Javascript `-10 % 3` returns `-1`
* Ruby/IRB, `-10 % 3` returns `2` **-- my expectation is here**


## Solution

Add this function some where in your Vimscript and throw away `%`.

```vim
" ((n % m) + m) % m` or `((-10 % 3) + 3) % 3` returns `2`
function! s:mod(n,m)
  return ((a:n % a:m) + a:m) % a:m
endfunction
```

I hope this saves someone some time somewhere out there. It's an hour I'll never
get back, but happy to give back.

**References**

* https://www.google.com/#q=-10+%25+3
* http://vimdoc.sourceforge.net/htmldoc/eval.html#expr6
* http://math.stackexchange.com/questions/519845/modulo-of-a-negative-number/519856
* https://en.wikipedia.org/wiki/Modulo_operation
* http://stackoverflow.com/questions/4467539/javascript-modulo-not-behaving

