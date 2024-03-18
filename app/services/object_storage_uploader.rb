# frozen_string_literal: true
require 'openssl'
require 'base64'
require 'net/http'
require 'time'
require 'uri'

class ObjectStorageUploader
  attr_accessor :access_key, :secret_key, :bucket, :region, :endpoint, :namespace

  def initialize(access_key, secret_key, bucket, region, endpoint, namespace)
    @access_key = access_key
    @secret_key = secret_key
    # The bucket name
    @bucket = bucket
    @region = region
    @endpoint = endpoint
    @namespace = namespace
  end

  def list_objects
    path = "/"
    send_request("GET", path)
  end

  # Retrieve a specific object from the bucket
  def get_object(object_name)
    path = "/#{URI.encode_www_form_component(object_name)}"
    response = send_request("GET", path)
    response.body
  end

  private

  def send_request(method, path)
    uri = URI("http://#{namespace}.compat.objectstorage.#{region}.oraclecloud.com#{path}")
    date = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    datetime = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    headers = {
      'host' => "#{namespace}.compat.objectstorage.#{region}.oraclecloud.com",
      'x-amz-date' => datetime,
      'x-amz-content-sha256' => 'UNSIGNED-PAYLOAD'
    }
    print "headers \n #{headers} \n"

    canonical_request = create_canonical_request(method, path, {}, headers, '')
    print "canonical_request \n  #{canonical_request} \n"
    string_to_sign = create_string_to_sign(canonical_request, datetime)
    print "string_to_sign \n #{string_to_sign} \n"

    signature = calculate_signature(datetime, string_to_sign)
    print "signature \n   #{signature} \n"

    authorization_header = build_authorization_header(datetime, headers['x-amz-date'], signature)
    print "authorization_header \n  #{authorization_header} \n"


    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    print "http \n"


    request = case method
              when "GET"
                Net::HTTP::Get.new(uri)
              end

    request['Authorization'] = authorization_header
    request['x-amz-date'] = datetime
    request['x-amz-content-sha256'] = 'UNSIGNED-PAYLOAD'
    print "request \n #{request} \n"
    http.request(request)
  end

  def create_canonical_request(method, uri, query_params, headers, payload)
    canonical_uri = uri
    canonical_query_string = query_params.map { |k, v| "#{k}=#{CGI.escape(v.to_s).gsub('+', '%20')}" }.sort.join('&')
    canonical_headers = headers.sort.map { |k, v| "#{k.downcase}:#{v}\n" }.join
    signed_headers = headers.keys.sort.join(';').downcase
    payload_hash = Digest::SHA256.hexdigest(payload)

    "#{method}\n#{canonical_uri}\n#{canonical_query_string}\n#{canonical_headers}\n#{signed_headers}\n#{payload_hash}"
  end

  def create_string_to_sign(canonical_request, datetime)
    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = "#{datetime[0,8]}/#{region}/s3/aws4_request"
    hashed_canonical_request = Digest::SHA256.hexdigest(canonical_request)

    "#{algorithm}\n#{datetime}\n#{credential_scope}\n#{hashed_canonical_request}"
  end

  def calculate_signature(datetime, string_to_sign)
    date_key = OpenSSL::HMAC.digest('sha256', "AWS4#{secret_key}", datetime[0,8])
    region_key = OpenSSL::HMAC.digest('sha256', date_key, region)
    service_key = OpenSSL::HMAC.digest('sha256', region_key, 's3')
    signing_key = OpenSSL::HMAC.digest('sha256', service_key, "aws4_request")
    OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)
  end

  def build_authorization_header(datetime, amz_date, signature)
    credential_scope = "#{datetime[0,8]}/#{region}/s3/aws4_request"
    signed_headers = "host;x-amz-date;x-amz-content-sha256"
    "AWS4-HMAC-SHA256 Credential=#{access_key}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
  end
end

