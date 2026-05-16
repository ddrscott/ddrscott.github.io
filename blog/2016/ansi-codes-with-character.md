---
title: "ANSI Codes with Character"
date: 2016-07-26
created: 2016-07-26T00:00:00Z
type: blog
status: settled
publish: [ddrscott]
source: import
prompt: "Import from blog post: 2016/ansi-codes-with-character.markdown"
---

# ANSI Codes with Character
This was a lightening talk given to the office about ANSI Escape Codes. Most of
the time, all 5 minutes of it, was spent explaining the code snippets.

<!-- more -->

[Wiki about ANSI Codes](https://en.wikipedia.org/wiki/ANSI_escape_code)

## What is an ANSI code?

ANSI Escape Codes are a nearly universal means of embedding display options in
computer terminals.

`\e[` is how to tell the terminal we're giving it a command instead just
outputting text. 

What does that mean?!? Let the examples do the talking.

## Color Examples

```bash
echo -e "\e[2J\e[32m It's not easy being green \e[0m"
echo -e "\e[2J\e[31m Apples are red  \e[0m"
```

```ruby
(30..37).each{|i| puts "i: \e[#{i}m #{i} \e[0m"}
```

## Position Examples

```ruby
x=`tput cols`.to_i
y=`tput lines`.to_i
loop do
  print "\e[s" # Save current cursor position
  print "\e[#{rand(y)};#{rand(x)}H"  # move to row/column
  print "💩"    # print POOP!
  print "\e[u" # restore position
  sleep(rand)
end
```

```bash
# Ruby oneliner troll
ruby -e 'x=`tput cols`.to_i; y=`tput lines`.to_i; loop {print "\e[s\e[#{rand(y)};#{rand(x)}H💩\e[u"; sleep(rand)}'
```


## ANSI-nine Examples
```bash
# Poop-field
curl -s https://raw.githubusercontent.com/ddrscott/ansinine/master/stars | ruby

# Smoke
curl -s https://raw.githubusercontent.com/ddrscott/ansinine/master/fire.rb | ruby
```
