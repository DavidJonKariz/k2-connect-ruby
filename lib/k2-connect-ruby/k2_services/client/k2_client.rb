require "yajl"

class K2Client
  attr_accessor :api_secret_key,
                :hash_body,
                :hash_header,
                :k2_signature

  # Initialize method
  def initialize(api_secret_key)
    raise K2NilSecretKey.new if api_secret_key.nil?
    @api_secret_key = api_secret_key
  rescue K2NilSecretKey => k2
    puts(k2.message)
  rescue StandardError => e
    puts(e.message)
  end

  # Method for parsing the Entire Request. Come back to it later to trim. L8r call it set_client_variables
  def parse_request(the_request)
    raise K2NilRequest.new if the_request.nil?
    if the_request.scheme.eql?("https")
      # The Response Body.
      @hash_body = Yajl::Parser.parse(the_request.body.string.as_json)
      # The Response Header
      @hash_header = Yajl::Parser.parse(the_request.headers.env.select{|k, _| k =~ /^HTTP_/}.to_json)
      # The K2 Signature
      @k2_signature = @hash_header["HTTP_X_KOPOKOPO_SIGNATURE"]
    else
      raise K2InsecureRequest.new
    end
  rescue K2NilRequest => k2
    puts(k2.message)
  rescue K2InsecureRequest => k3
    puts(k3.message)
  rescue StandardError => e
    puts(e.message)
  end
end