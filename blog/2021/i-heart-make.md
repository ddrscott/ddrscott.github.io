---
title: "I Heart Make"
date: 2021-02-24
created: 2021-02-24T00:00:00Z
type: blog
status: settled
tags: [makefile, pdf, rar]
publish: [ddrscott]
source: import
description: "I heart Make: How to Convert CBR to PDF using a Makefile"
image: /images/2021/make-pdf.png
prompt: "Import from blog post: 2021/i-heart-make.markdown"
---

# I Heart Make<br/><small>How to Convert CBR to PDF using a Makefile</small>

<img class="featured" src="/images/2021/make-pdf.png" alt="Makefile Header" />

Good news: I got a shiny new e-ink reader.<br/>
Bad news: It doesn't support CBR (Comic Book Reader) files.</br>
Good news: I recently read the [manual](https://www.gnu.org/software/make/manual/make.html) on `make` because I had trouble sleeping.</br>
Bad news: It didn't put me to sleep.

## Problem

I have a bunch of CBR ([Comic Book Reader](https://en.wikipedia.org/wiki/Comic_book_archive)) files that I need to convert to PDF ([Portable Document Format](https://en.wikipedia.org/wiki/PDF)) files. 

The general step for a single file would look something like:

```sh
rar x naruto-001.cbr .images             # 1) unpack archive into .images/*.jpg
magick convert .images/* naruto-001.pdf  # 2) convert all the images into pdf file
rm -rf .images                           # 3) remove the images.
```

But we're not here to convert a single file. We're here to convert a ton of them.

Without `make`, we could probably:

1. extract the snippet to a bash script named `foo.sh`
2. run the script on one file with `./foo.sh naruto-001.cbr`
3. run the script on all the files with `find . -name '*.cbr' -exec ./foo.sh {} \;`.

Then we'd curse when errors come up because:

1. we forgot to make the script executable. `chmod +x foo.sh`
2. we forget to add `-e` so the script stops when something goes wrong. `#!/bin/bash -e`
3. something with `find` never works first try!
4. file `naruto-301.cbr` failed, and we don't want to run `naruto-{000-300}.cbr` again!

## Solution

Make way for `make`! A `Makefile` can handle most of our iteration problems automatically.
It already has the facilities to handle multiple files, error handling, and skipping finished files.

### A Full `Makefile`

```make
cbr_files = $(wildcard *.cbr)
pdf_files = $(cbr_files:.cbr=.pdf)
image_dir = .images-$<

all: ${pdf_files}
	@echo All done

clean:
	rm ${pdf_files}

%.pdf: %.cbr
	@echo Building $< into $@
	rar x $< ${image_dir}/
	find ${image_dir}/ -size 0 -ls -delete
	magick convert ${image_dir}/* $@
	rm -rf ${image_dir}
	@echo $@ is ready
```

### `Makefile` with in-Line Comments

```make
# 1. Get a list of all CBR files in the current directory
cbr_files = $(wildcard *.cbr)

# 2. Get a list of all PDFs I want to build by renaming CBR list to PDF
pdf_files = $(cbr_files:.cbr=.pdf)

# 3. Set where the unpacked images should go. We'll delete them after each build
image_dir = .images-$<

# 4. The first target specified is always the default when we run `make` without any arguments
all: ${pdf_files}
	@echo All done

# 5. `make clean` will remove all the generated PDFs
clean:
	rm ${pdf_files}

# 6. Use Pattern Rules to build an individual PDF file
%.pdf: %.cbr
	# use @ to prevent `make` from printing the command it is executing
	@echo Building $< into $@
	#               ^      ^
	#               |      |
	#               |      |
	#               |      +- foo.pdf
	#               |
	#               +- foo.cbr
	#
	rar x $< ${image_dir}/
	#   ^  ^     ^
	#   |  |     |
	#   |  |     +- unpack to destination directory
	#   |  |
	#   |  +- foo.cbr
	#   |
	#   +- extract
	#
	find ${image_dir}/ -size 0 -ls -delete
	#         ^           ^     ^     ^
	#         |           |     |     |
	#         |           |     |     +- delete the file
	#         |           |     |
	#         |           |     +- print `ls -l` of the file
	#         |           |
	#         |           +- only files with zero size
	#         +- find in image directory
	# 
	magick convert ${image_dir}/* $@
	#                   ^          ^
	#                   |          |
	#                   |          +- foo.pdf
	#                   |
	#                   +- all files in image directory
	# 
	rm -rf ${image_dir}
	#           ^
	#           |
	#           +- delete entire image director. We don't need it anymore.
	# 
	@echo $@ is ready
```

Code the contents of either snippet into a `Makefile` and put the `Makefile` in the same directory as all the `cbr` files.
Then execute `make` and a pile of `pdf` files should get created.
If we run with `make -j 4` it will even run multiple files in parallel where `4` is the number of parallel jobs you'd
like to run. Revel in the code we _didn't_ have to write to enable parallelism!


## A Little Deeper

The `make` magic occurs in step 6 with `%.pdf: %.cbr`.
This is officially called a [pattern rule](https://www.gnu.org/software/make/manual/make.html#Pattern-Rules) according to the documentation.
It tells `make` to build a target for any file suffixed with `.pdf` and set a dependency for the same file suffixed with `.cbr`.
With the pattern rule in place and using `$<` to represent the first dependency and `$@` to represent the target file, we can script out the remaining build.

Another piece of magic is in step #3.
`image_dir = .images-$<` is a variable assignment referencing `$<`.
The `=` assignment operator in `make` is a macro, meaning it won't get evaluated until the variable is referenced in a target.
This can be surprising at first, but in this case, it provides a nice unique directory for our images to get unpacked.
More details about Makefile variable use can be found in their [docs](https://www.gnu.org/software/make/manual/html_node/Using-Variables.html#Using-Variables).

## Conclusion

`make` isn't the shinest build system around.
[Wikipedia](https://en.wikipedia.org/wiki/List_of_build_automation_software) says there are over 40 of them, but in my opinion, `make` get's the most value for the least amount of effort.
`make` provides dependency checking, multiple job support, and simple bash-like syntax without the need to `npm install the_world`.

Thanks for `make`ing it this far. Let me know how you `make` use of `make` in the comments below.
