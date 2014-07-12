#!/usr/bin/env ruby
require 'io/console'

class RainbowTty
  def random_color
    red,green,blue = rand(5), rand(5), rand(5)
    "\e[38;5;#{16 + (red * 36) + (green * 6) + blue}m"
  end
  def say(text)
    (@queue ||= []) << text
    @sayer ||= Thread.new do
      while true
        if word = @queue.shift
          `say #{Shellwords.escape word}`
        else
          sleep 0.1
        end
      end
    end
  end

  def start
    puts "<CTRL-C to Exit>"
    random_color
    word = ''
    while true
      c = STDIN.getch
      if c == "\u0003"
        break
      elsif c == "\r"
        print "\n", random_color
        say(word) unless  word.empty?
      elsif c == "\u007F"
        print "\b \b" # backspace
      elsif c == ' '
        print c, random_color
        say(word) unless word.empty?
      else
        # build up the word
        word << c 
        say(c)
        print c
      end
    end
  end
end
RainbowTty.new.start
