module Transbank
  module Webpay
    class Client
      attr_accessor :uri, :http

      HEADER = { 'Content-Type' => 'application/soap+xml; charset=utf-8' }.freeze

      def initialize(wsdl_url)
        opt = Transbank::Webpay.configuration.http_options
        self.uri = URI.parse wsdl_url
        self.http = Net::HTTP.new uri.host, uri.port

        # load options
        define_options(opt)

        # default options
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def post(xml)
        http.post(uri.path, xml, HEADER)
      end

      private

      def define_options(opt = {})
        opt.each { |attr, value| http.__send__("#{attr}=", value) }
      end
    end
  end
end
