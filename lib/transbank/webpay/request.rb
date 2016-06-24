module Transbank
  module Webpay
    class Request
      attr_accessor :client, :document, :action

      def initialize(wsdl_url, action, params = {})
        @action = action
        @document = Document.new(wsdl_url, action, params)
        @client = Client.new wsdl_url
      end

      def response
        rescue_exceptions = Transbank::Webpay.configuration.rescue_exceptions

        @response ||= begin
          Response.new client.post(document.to_xml), action
        rescue match_class(rescue_exceptions) => error
          ExceptionResponse.new error, action
        end
      end

      private

      def match_class(exceptions)
        m = Module.new
        (class << m; self; end).instance_eval do
          define_method(:===) do |error|
            (exceptions || []).include? error.class
          end
        end
        m
      end
    end
  end
end
