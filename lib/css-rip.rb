#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'csv'

# Converts style takes to CSS blocks.
class CssRip

  # style attribute of element with src attribute appended if element is an image
  #
  # @param elm [Element]
  # @return [String] style attribue + image['src']
  def style_plug_attrs(elm)
    style = elm['style']
    if elm.name == 'img' and src = elm['src']
      style += "; background-image: url('#{src}')"
    end
    if elm.name == 'font' and faces = elm['face']
      style += "; font-family: #{faces}"
    end
    style
  end

  # parses the styles into a hash of meta stuff
  # @return [Hash] keys: class, comments, styles
  def styles_to_blocks(styles)
    # default to 0, value used to keep track of duplicate element types
    elements = Hash.new{0} 

    styles.collect do |style, elms|
      name = elms.first.name

      {
        class: "#{name}-#{elements[name]+=1}",
        comments: elms.collect{|c|c.path},
        styles: style.split(";").collect{|c| c.strip}.select{|s| s and !s.empty?}.collect{|c| c+';'}
      }
    end
  end

  # takes the array of blocks and renders the rest of the CSS syntax
  # order the blocks based on class names
  def output_css(blocks)
    # render the CSS code
    sorted = blocks.sort_by{|s| s[:class]}.collect do |block|
      <<-CSS
/*
 * #{block[:comments] * "\n * "}
 */
.#{block[:class]} {
    #{block[:styles] * "\n    "}
}
CSS
    end.join("\n\n")
    puts sorted
  end

  def run
    url = ARGV.shift or raise 'url should be first arg'
    doc = Nokogiri(open(url))

    # group by distinct style declartions
    styles = doc.search('[style]').group_by{|g| style_plug_attrs(g)}

    # extract various elements of each style
    blocks = styles_to_blocks(styles)

    output_css(blocks)
  end
end
CssRip.new.run
