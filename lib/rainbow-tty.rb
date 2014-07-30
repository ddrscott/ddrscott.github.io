#!/usr/bin/env ruby

require 'io/console'
require 'shellwords'
require 'thread'

class RainbowTty
  def initialize
    @queue = Queue.new
  end

  def random_color
    red,green,blue = rand(5), rand(5), rand(5)
    "\e[38;5;#{16 + (red * 36) + (green * 6) + blue}m"
  end

  def say(text)
    @queue.push(text.dup) unless text.empty?
  end

  def handle_queue
    Thread.new do
      while word = @queue.pop
        # puts "#{(Shellwords.escape word).inspect}"
        `say #{Shellwords.escape word}`
      end
    end
  end

  def start
    puts "<CTRL-C to Exit>#{random_color}"
    handle_queue
    word = ''
    while c = STDIN.getch and c != "\u0003"
      if c == "\r"
        print "\r\n", random_color
        say(word)
        word.clear
      elsif c == "\u007F"
        print "\b \b" # backspace
        word.chop!    # remove right most character
      elsif c == ' '
        print c, random_color
        say(word)
        word.clear
      elsif c == "\e"
        # consume arrow keys
        print c, STDIN.getch, STDIN.getch 
      else
        # build up the word
        word << c 
        print c
      end
    end
  end
end
RainbowTty.new.start
