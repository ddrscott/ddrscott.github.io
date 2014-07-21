#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = ARGV.shift or raise 'url should be first arg'
doc = Nokogiri(open(url))
doc.search('[style]').group_by{|g| g['style']}.each{|s, elms| puts s, "  -#{elms.collect{|c| c.path} * "\n  -"}"};

exit 0
