---
title: "FZF + WordNet = Dictionary"
date: 2017-06-12
created: 2017-06-12T00:00:00Z
type: blog
status: settled
publish: [ddrscott]
source: import
image: /images/fzf_dictionary_demo.gif
prompt: "Import from blog post: 2017/fzf-dictionary.markdown"
---

# FZF + WordNet = Dictionary

<img src="/images/fzf_dictionary_demo.gif" alt="FZF Dictionary" />

`FZF + WordNet = Dictionary`. FZF is a fuzzy finding command line tool. WordNet
is a dictionary structured for developers. When married together, we can get
a snappy dictionary to help us find just the right word for any occasion.

<!-- more -->

## Install Required Program
 
Before making our new shell function, lets install the required programs.

1. https://github.com/junegunn/fzf
2. http://wordnetweb.princeton.edu/perl/webwn

These directions are for Max OSX with `homebrew` installed. If you're on
a different system, read the docs from the sites above to get the programs for
your operating system.

```sh
brew install fzf
brew cask install xquartz
brew install wordnet
```

## FZF

FZF stands for Fuzzy Finder. It is a program which enables the user to filter
a set of lines from standard in and feed those line back to standard out.
A basic example is: `find . | fzf`. This presents a list of all files in the
current working directory and prompts the user for input. As you type letters, the
list will narrow, keeping only the items matching the search criteria. After
selecting an entry from the list the line or lines chosen is printed to standard
out. It provides a nifty argument `--preview` which can execute a program and
display its output as an aside in the terminal. We'll write more about FZF in the
future.


## WordNet

> WordNet is a large lexical database of English. Nouns, verbs, adjectives and
> adverbs are grouped into sets of cognitive synonyms (synsets), each expressing
> a distinct concept. Synsets are interlinked by means of conceptual-semantic
> and lexical relations. The resulting network of meaningfully related words and
> concepts can be navigated with the browser. WordNet is also freely and
> publicly available for download. WordNet's structure makes it a useful tool
> for computational linguistics and natural language processing.
> 
> WordNet superficially resembles a thesaurus, in that it groups words together
> based on their meanings. However, there are some important distinctions.
> First, WordNet interlinks not just word forms—strings of letters—but specific
> senses of words. As a result, words that are found in close proximity to one
> another in the network are semantically disambiguated. Second, WordNet labels
> the semantic relations among words, whereas the groupings of words in
> a thesaurus does not follow any explicit pattern other than meaning
> similarity.

Using WordNet we can find information similar to what is in a dictionary and
thesaurus combined.

Example output of looking up `happy` is:
```text
% wn happy -over

Overview of adj happy

The adj happy has 4 senses (first 2 from tagged texts)

1. (37) happy -- (enjoying or showing or marked by joy or pleasure; "a happy smile"; "spent many happy days on the beach"; "a happy marriage")
2. (2) felicitous, happy -- (marked by good fortune; "a felicitous life"; "a happy outcome")
3. glad, happy -- (eagerly disposed to act or to be of service; "glad to help")
4. happy, well-chosen -- (well expressed and to the point; "a happy turn of phrase"; "a few well-chosen words")
```

`xquartz` is needed since the WordNet package also works in GUI mode. The GUI
app has a useful interface and could be more intuitive to use if you don't mind
clicking around. The GUI app can be started with `wnb`, but we're not here for
GUI stuff. Let's move on to making our terminal script.


## Shell Script

The following 3 functions can be used individually and are helpful all on their
own. Add these directly into your shell profile or in a separate file and source
it from the profile.

`fold` is normally a built in command. By default it adds newlines when text
overflows the terminal, but it doesn't do it in an easy to read fashion. The
default behavior can break in the middle of a word and assumes a terminal width
of 80 columns. Our `fold` function breaks at spaces and passes the whole
terminal width to it when no other arguments are provided.

```sh
# Default `fold` to screen width and break at spaces
function fold {
  if [ $# -eq 0 ]; then
    /usr/bin/fold -w $COLUMNS -s
  else
    /usr/bin/fold $*
  fi
}
```

`spell` is the FZF portion of our script. This fuzzy matches the built in Mac
dictionary with a preview window containing the WordNet overview of the selected
word.

```sh
# Use `fzf` against system dictionary
function spell {
  cat /usr/share/dict/words | fzf --preview 'wn {} -over | fold' --preview-window=up:60%
}
```

The `dic` script uses `spell` to help find a word then outputs WordNet's
definition.

```sh
# Lookup definition of word using `wn $1 -over`.
# If $1 is not provided, we'll use the `spell` command to pick a word.
#
# Requires:
#   brew install wordnet
#   brew install fzf
function dic {
  if [ $# -eq 0 ]; then
    wn `spell` -over | fold
  else
    wn $1 -over | fold
  fi
}
```

Here's another demo of the `dic` function:
<img src="/images/fzf_dict_demo2.gif" alt='FZF Dictionary Demo 2' />

## Conclusion

Gluing programs together with `fzf --preview` is fun. Let us know what other
recipes you come up with in the comments below.
