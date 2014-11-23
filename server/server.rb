#!/usr/bin/env ruby

require 'optparse'
require 'webrick'
require 'cgi'
require "net/https"
require "uri"
require "securerandom"

class Server
  AUTHORIZE_URL = "https://api.quizlet.com/oauth/token"
  def initialize(client_id:, secret_key:, redirect_url:, port: 8000)
    @client_id = client_id
    @secret_key = secret_key
    @redirect_url = redirect_url
    @port = port
  end

  def start!
    server = WEBrick::HTTPServer.new(Port: @port)

    server.mount_proc '/' do |request, response|
      if request.query["error"]
        response.body << "Something went wrong...\n"
        response.body << "error: #{request.query["error"]}"
      elsif request.query["state"] != @state
        response.body << request.query.inspect
        response.body << "The random number you gave doesn't match with the one returned by the server\n"
        response.body << "Try restarting the server and using the new URL it gives you on startup"
      else
        response.body << "Requesting a key from the server...\n"
        server_response = request_authorization(request.query["code"])
        if server_response.code != "200"
          response.body << "Oh no. Response code: #{server_response.code}\n"
          response.body << server_response.body
        else
          response.body << "Great success!\n"
          response.body << server_response.body
        end
      end
    end

    trap 'INT' do server.shutdown end

    server.start
  end

  def request_authorization(code)
    uri = URI.parse(AUTHORIZE_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    # http.set_debug_output(STDOUT)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.path)
    request.basic_auth(@client_id, @secret_key)
    request.set_form_data(code: code, redirect_uri: @redirect_url, grant_type: 'authorization_code')

    return http.start {|http| http.request(request) }
  end

  def create_uri
    @state = SecureRandom.hex
    "https://quizlet.com/authorize?response_type=code&client_id=#{@client_id}&scope=read%20write_set&&state=#{@state}"
  end
end

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "usage: #{File.basename $PROGRAM_NAME} <arguments> [options]"

  opts.on('--id <client id>', 'Quizlet client ID (required)') do |id|
    options[:client_id] = id
  end

  opts.on('--key <secret key>', 'secret key (required)') do |key|
    options[:secret_key] = key
  end

  opts.on('--url <redirect url>', 'redirect url (required)') do |url|
    options[:redirect_url] = url
  end

  opts.on('--port <port>', 'port') do |port|
    options[:port] = port
  end

  opts.on('-h', '--help', 'display this message') do
    puts opts
    exit
  end

  opts.parse!
end

if %i{ client_id secret_key redirect_url }.any? {|k| !options[k]}
  puts parser
  exit
end

server = Server.new(**options)

puts "Please copy and paste this URL into your browser and click 'agree'."
puts "If it doesn't work, you may need to have your router forward port 8000 to this machine's port 8000."
puts
puts server.create_uri
puts
server.start!
