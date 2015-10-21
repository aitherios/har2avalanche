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

$version = '1.1.0'

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

      opts.on("-b",
              "--best-try",
              "Tries the best to simulate reality",
              "flags --with-referer --with-headers") do |flag|
        options.with_referer = flag
        options.with_headers = flag
      end

      opts.on("--include-hosts x,y,z...", Array, "Hosts to be whitelisted") do |list|
        options.include_hosts = list
      end

      opts.on("--exclude-hosts x,y,z...", Array, "Hosts to be blacklisted") do |list|
        options.exclude_hosts = list
      end

      opts.on("-R", "--with-referer", "Add <REFERER> directive") do |flag|
        options.with_referer = flag
      end

      opts.on("-H", "--with-headers", "Add <ADDITIONAL_HEADER> directives") do |flag|
        options.with_headers = flag
      end

      opts.on("--include-headers x,y,z...",
              Array,
              "Headers to be whitelisted",
              "flags --with-headers") do |list|
        options.with_headers = true
        options.include_headers = list
      end

      opts.on("--exclude-headers x,y,z...",
              Array,
              "Headers to be blacklisted",
              "flags --with-headers") do |list|
        options.with_headers = true
        options.exclude_headers = list
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

  def referer_header
    headers = @entry['request']['headers'].select do |h|
      h['name'] == 'Referer'
    end
    headers.empty? ? {} : headers.first
  end

  def level
    referer_header.empty? or referer_header['value'] == uri.to_s ? 1 : 2
  end

  def referer_directive
    directives = ''
    if level == 2
      directives << "<REFERER #{referer_header['value']}>"
    end
    directives
  end

  def additional_header_directives
    directives = ''
    @entry['request']['headers'].each do |header|
      unless @options.include_headers.nil?
        next unless @options.include_headers.include?(header['name'])
      end

      unless @options.exclude_headers.nil?
        next if @options.exclude_headers.include?(header['name'])
      end

      directives << "<ADDITIONAL_HEADER=\"#{header['name']}: #{header['value']}\"> "
    end
    directives
  end

  def to_s
    output = "#{level} #{method} #{uri}"
    output << " #{referer_directive}" if @options.with_referer
    output << " #{additional_header_directives}" if @options.with_headers
    output
  end
end

ARGV << '--help' if ARGV.empty?
options = Optparse.parse(ARGV)

file = File.read(options.filepath)
data_hash = JSON.parse(file)

entries = data_hash["log"]["entries"].map { |e| Entry.new(e, options) }
entries.each do |entry|
  unless options.include_hosts.nil?
    next unless options.include_hosts.include?(entry.host)
  end

  unless options.exclude_hosts.nil?
    next if options.exclude_hosts.include?(entry.host)
  end

  puts entry
end
