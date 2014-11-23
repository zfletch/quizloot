require "net/https"
require "uri"
require "json"

class Request
  API_URL="https://api.quizlet.com/2.0"

  def initialize(key:, api_key:)
    @key = key
    @api_key = api_key
  end

  def get_all_user_sets(user:)
    user_get_request(URI.parse(API_URL + "/users/#{user}/sets"))
  end

  def get_user_sets(set_ids:)
    raise RequestError, "set IDs must be numeric" unless set_ids.all? {|id| id =~ /\A\d+\z/}

    user_get_request(URI.parse(API_URL + "/sets?set_ids=#{set_ids.join(',')}"))
  end

  def get_public_sets(set_ids:)
    raise RequestError, "set IDs must be numeric" unless set_ids.all? {|id| id =~ /\A\d+\z/}

    user_get_request(URI.parse(API_URL + "/sets?client_id=#{@api_key}&set_ids=#{set_ids.join(',')}"))
  end

  class RequestError < Exception
  end

  private

  def user_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    # http.set_debug_output(STDOUT)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER # you may need to set this to VERIFY_NONE if it doesn't work

    request = Net::HTTP::Get.new(uri.request_uri, { "Authorization" => "Bearer #{@key}" })

    response = http.start {|http| http.request(request) }

    raise RequestError, "Error #{response.code}:\n#{response.body}" if response.code != "200"

    JSON.parse(response.body)
  end

  def public_get_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    # http.set_debug_output(STDOUT)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER # you may need to set this to VERIFY_NONE if it doesn't work

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.start {|http| http.request(request) }

    raise RequestError, "Error #{response.code}:\n#{response.body}" if response.code != "200"

    JSON.parse(response.body)
  end
end
