#!/usr/bin/env ruby
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'json'
require 'optparse'
require 'ostruct'
require 'uri'

$version = '0.2.0'

class Optparse

  def self.parse(args)
    options = OpenStruct.new

    options.with_headers = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

      opts.separator ""

      opts.on("-f", "--file FILE", "HAR file to be parsed") do |file|
        options.filepath = file
      end

      opts.on("--with-headers", "Add <ADDITIONAL_HEADER> directives") do |flag|
        options.with_headers = flag
      end

      opts.on("--whitelist [host1,host2...]", "Hosts to be whitelisted, block everything else") do |hosts|
        options.whitelist = hosts
      end

      opts.on("--blacklist [host1,host2...]", "Hosts to be blacklisted, pass everything else") do |hosts|
        options.blacklist = hosts
      end

      opts.separator ""

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.on_tail("-v", "--version", "Show version") do
        puts $version
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end
end

class Entry

  def initialize(data, options)
    @entry = data
    @options = options
  end

  def uri
    @uri ||= URI::parse(@entry['request']['url'])
  end

  def host
    uri.host
  end

  def method
    @entry['request']['method'].upcase
  end

  def level
    headers = @entry['request']['headers'].select { |h| h['name'] == 'Referer' }
    headers.empty? or headers.first['value'] == uri.to_s ? 1 : 2
  end

  def additional_headers
    directives = ''
    @entry['request']['headers'].each do |header|
      directives << " <ADDITIONAL_HEADER=\"#{header['name']}: #{header['value']}\">"
    end
    directives
  end

  def to_s
    output = "#{level} #{method} #{uri}"
    output << " #{additional_headers}" if @options.with_headers
    output
  end
end

ARGV << '--help' if ARGV.empty?
options = Optparse.parse(ARGV)

file = File.read(options.filepath)
data_hash = JSON.parse(file)

entries = data_hash["log"]["entries"].map { |e| Entry.new(e, options) }
entries.each do |entry|

  unless options.whitelist.nil?
    next unless options.whitelist.include?(entry.host)
  end

  unless options.blacklist.nil?
    next if options.blacklist.include?(entry.host)
  end

  puts entry
end
