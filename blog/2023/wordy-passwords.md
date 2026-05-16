---
title: "Wordy Passwords"
date: 2023-01-05
created: 2023-01-05T00:00:00Z
type: blog
status: settled
tags: [security]
publish: [ddrscott]
source: import
description: "How to Generate a Wordy Password"
image: https://imgs.xkcd.com/comics/password_strength.png
prompt: "Import from blog post: 2023/wordy-passwords.md"
---

# How to Generate a Wordy Password

## TL;DR
```sh
grep -E '^[a-z]{3,}$' /usr/share/dict/words | shuf -n4 | paste -sd- -
```


## Intro

It is 2023 and passwords are still a thing. They are hard to remember and easy to crack.
Many sites talk about using words instead of letters, numbers and symbols:

- https://www.useapassphrase.com/
- https://www.nexcess.net/web-tools/secure-password-generator/
- https://xkpasswd.net/s/

Most of them were inspired by this comic:

<img class="featured" src="https://imgs.xkcd.com/comics/password_strength.png" alt="XKCD" />

We recently needed to generate hard to guess, but recognizable URLs to share
some data analysis with clients. We also planned to speak the URLs to our clients via video conferencing.
GUIDs (Globally Unique Identifiers) are nearly impossible to comprehend and speak accurately:
`f95b9390f8fe5d7a6aecd9d563b5f8a5` and `b987370e-6906-498b-a5d4-84c1c92c6e64`,
so Wordy Passwords™ (TM cause you heard it here first!) came to mind to meet all the requirements.

There are sites that can generate these things which we could scrape as needed, but we thought there's
got to be a simpler way.

## Simpler Way

If you're on Mac or Linux, the simpler way is already in your terminal.

```sh
grep -E '^[a-z]{3,}$' /usr/share/dict/words | shuf -n4 | paste -sd- -
```

Let's explain:

- `/usr/share/dict/words` is a file with a list of all English words, about 100k of them.
- `grep -E '^[a-z]{3,}$' /usr/share/dict/words` filters for lowercase words with 3 or more letters.
- `shuf -n4` picks 4 random entries from the filtered list. Change `4` to whatever is needed for your use case.
- `paste -sd- -` joins all the lines with `-` symbol. This can also be changed to `-sd ' '` for spaces or `-sd ','` for commas, etc.
  Note, the last `-` tells the command to read from `/dev/stdin` and is necessary on Mac.

Use `man grep`, `man shuf`, or `man paste` to get additional details about each command.

Example Output:

- `mentions-grouses-datelines-mouses`
- `cellulite-sukiyaki-ardner-rusted`
- `naturalness-indicate-dependent-beset`
- `irony-excursion-flashily-crawl`

We can then use these in our data generation URLs to get something like:

- `https://your.dataturd.com/mentions-grouses-datelines-mouses`
- `https://your.dataturd.com/cellulite-sukiyaki-ardner-rusted`
- `https://your.dataturd.com/naturalness-indicate-dependent-beset`
- `https://your.dataturd.com/irony-excursion-flashily-crawl`

In case `/usr/share/dict/words` doesn't exist, try installing with `apt install wamerican`.
To pick another language try `apt search wordlist` which will return a bunch of other options for specific languages.

### Windows PC

If you're in Windows, we'd recommend using [WSL](https://learn.microsoft.com/en-us/windows/wsl/install).
This will provide access to a Linux shell which has all the aforementioned commands.

If you're not sure where to type in these fancy commands, try searching for "learn linux terminal". We'll eventually post additional
articles regarding our love for the terminal and why commands like these keep us in it.

## Alternative Word List

We experimented with other word lists. [doyle.txt](https://www.dataturd.com/words/doyle.txt) contains words extracted from books
featuring Sherlock Holmes. Source code for how the word list was built is located at https://github.com/ddrscott/wordy-passwords .

Feel free to search the Internet for other word lists.

## Closing

The terminal is a magical place where mountains of code can be replaced with a few razor sharp commands.
`shuf` and `paste` can make short work of many tasks. Let us know what you come up with in the comments below!
