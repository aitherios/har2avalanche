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

$version = '0.1.0'

class Optparse

  def self.parse(args)
    options = OpenStruct.new

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename(__FILE__)} [file.har]"

      opts.separator ""

      opts.on("-f", "--file FILE", "HAR file to be parsed") do |file|
        options.filepath = file
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

ARGV << '--help' if ARGV.empty?
options = Optparse.parse(ARGV)

file = File.read(options.filepath)
data_hash = JSON.parse(file)

data_hash["log"]["entries"].each do |entry|

  unless options.whitelist.nil?
    uri = URI::parse(entry['request']['url'])
    next unless options.whitelist.include?(uri.host)
  end

  unless options.blacklist.nil?
    uri = URI::parse(entry['request']['url'])
    next if options.blacklist.include?(uri.host)
  end

  puts "#{entry['request']['method']} #{entry['request']['url']}"
end
