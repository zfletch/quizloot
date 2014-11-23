#!/usr/bin/env ruby

require "optparse"
require "json"
require_relative "../lib/request.rb"

def show_banner(parser)
  puts parser
  puts
  puts %q{Commands:
  pull [file]    [--api_key <key>] [--user <user>] [--key <key>] [--sets <id ..>] [--rcfile <file>]
  push [file ..] [--api_key <key>] [--user <user>] [--key <key>] [--sets <id ..>] [--rcfile <file>]
  conf           [--api_key <key>] [--user <user>] [--key <key>] [--rcfile <file>]}
end

def parse!
  options = {
    api_key: nil,
    user: nil,
    key: nil,
    sets: nil,
    rcfile: "~/.qzierc",
  }
  commands = [
    :push,
    :pull,
    :conf,
  ]

  parser = OptionParser.new do |opts|
    opts.banner = "usage: #{File.basename $PROGRAM_NAME} <command> [file ..] [options]"

    opts.on('--api_key <key>', 'Quizlet Client ID (defaults to api_key in rcfile)') do |key|
      options[:api_key] = key
    end

    opts.on('--user <user>', 'username of the quizlet user (defaults to user in rcfile)') do |user|
      options[:user] = user
    end
    
    opts.on('--key <key>', "the user's access token (defaults to key in rcfile)") do |key|
      options[:key] = key
    end

    opts.on('--sets <id ..>', Array, 'list of set IDs (defaults to all sets if user given)') do |sets|
      options[:sets] = sets
    end

    opts.on('--rcfile <file>', 'file with configuration options (defaults to ~/.qzierc)') do |file|
      options[:rcfile] = file
    end

    opts.on('-h', '--help', 'display this message') do
      show_banner(parser)
      return
    end
  end

  begin

    parser.parse!

    command = ARGV.shift
    raise "no command given" if command.nil?
    command = command.to_sym
    raise "unknown command: #{command}" unless commands.member?(command)

    case command

    when :push
      options = options.reject {|_, val| val.nil?}
      options = get_options_from_rcfile(File.expand_path(options[:rcfile]), options)
      raise "not implemented"

    when :pull
      options = options.reject {|_, val| val.nil?}
      options = get_options_from_rcfile(File.expand_path(options[:rcfile]), options)
      request = Request.new(key: options[:key], api_key: options[:api_key])

      if options[:key] && options[:user] && !options[:sets]
        json = request.get_all_user_sets(user: options[:user])
        puts JSON.pretty_generate(json)
      elsif options[:key] && options[:sets]
        json = request.get_user_sets(set_ids: options[:sets])
        puts JSON.pretty_generate(json)
      elsif options[:api_key] && options[:sets]
        json = request.get_public_sets(set_ids: options[:sets])
        puts JSON.pretty_generate(json)
      else
        raise "pull requires a user key, user key and list of sets, or api key and list of sets"
      end

    when :conf
      rc_options = options.select do |key, val|
        %i{ api_key user key }.member?(key) && !val.nil?
      end
      if rc_options == {}
        read_conf_file(File.expand_path(options[:rcfile]))
      else
        write_conf_file(File.expand_path(options[:rcfile]), rc_options)
      end
    end

  rescue Request::RequestError => exception
    puts exception
    exit 1
  rescue Exception => exception
    # puts exception.backtrace
    puts exception
    show_banner(parser)
    exit 1
  end
end

def get_options_from_rcfile(filename, options)
  if !File.exists?(filename)
    warn "configuration file not found: #{filename}"
    return options
  end

  JSON.parse(File.read(filename), symbolize_names: true).merge(options)
end

def write_conf_file(filename, options)
  if File.exists?(filename) 
   options = JSON.parse(File.read(filename), symbolize_names: true).merge(options)
  end

  options = options.select {|key, val| val != ""}

  File.open(filename, 'w', 0600) do |file|
    file.puts JSON.pretty_generate(options)
  end
end

def read_conf_file(filename)
  puts JSON.pretty_generate(JSON.parse(File.read(filename), symbolize_names: true))
end

parse!
