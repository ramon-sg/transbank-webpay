Transbank::Webpay.configure do |config|
  config.url               = 'WEBPAY_SOAP_URL'
  config.wsdl_nullify_url  = 'NULLIFY_WEBPAY_SOAP_URL'
  config.cert_path         = 'ABSOLUTE_PATH_TO_CRT_FILE'
  config.key_path          = 'ABSOLUTE_PATH_TO_KEY_FILE'
  config.server_cert_path  = 'ABSOLUTE_PATH_TO_SERVER_CRT_FILE'
  config.commerce_code     = 'COMMERCE_CODE'

  # These are the default options for Net::HTTP
  # config.http_options = { read_timeout: 80 }

  # ignores any exception passed as argument
  # not capture any exception: config.rescue_exceptions []
  # Default is:
  #  [
  #   Net::ReadTimeout, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
  #   EOFError,	Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
  # ]
  # config.rescue_exceptions = [
  #   Net::ReadTimeout, Timeout::Error,
  #   Transbank::Webpay::Exceptions::InvalidSignature
  # ]
end
