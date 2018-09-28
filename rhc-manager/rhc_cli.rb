#!/usr/bin/env ruby
require_relative './rhc_api.rb'
require 'httparty'
require 'optparse'
require 'tty-spinner'

options = {}

#Parsing CLI arguments
OptionParser.new do |opts|
  opts.banner = "Usage: rhc_cli.rb [options]"
  opts.on("-i", "--id", "Project ID") do |id|
   options[:id] = id
  end
  opts.on("-t", "--tag", "Project tag") do |tag|
   options[:tag] = tag
  end
end.parse!

#Checking for flags and arguments
if (options[:id] && ARGV[0]) && (options[:tag] && ARGV[1])
  puts "Starting new build"
  API.build(ARGV[0], ARGV[1])
elsif options[:id] && ARGV[0]
  if options[:tag] && ARGV[1] == nil
    puts "Error: Please provide a tag"
  else
    spinner = TTY::Spinner.new("[:spinner]Gathering data ...", format: :classic)
    spinner.run('Done!') do
      API.response(ARGV[0])
    end
  end
else
  puts "There has been an error..."
end

##Print out input for testing (Uncomment if you want to test)
# puts "\nArguments used:"
# p options
# p ARGV
