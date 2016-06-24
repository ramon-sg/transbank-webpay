# rubocop:disable all
module Transbank
  module Webpay
    class Response
      attr_accessor :content, :action, :attributes, :errors, :exception

      RESPONSE_CODE = {
        get_transaction_result: {
          '0'   => 'transacción aprobada',
          '-1'  => 'rechazo de transacción',
          '-2'  => 'transacción debe reintentarse',
          '-3'  => 'error en transacción',
          '-4'  => 'rechazo de transacción',
          '-5'  => 'rechazo por error de tasa',
          '-6'  => 'excede cupo máximo mensual',
          '-7'  => 'excede límite diario por transacción',
          '-8'  => 'rubro no autorizado'
        },
        default: {
          '0'   => 'aprobado',
          '-98' => 'Error'
        }
      }

      def initialize(content, action)
        self.content = content
        self.action = action
        self.attributes = xml_result
        self.errors = []
        validate!
      end

      def body
        content.body
      end

      def http_code
        content.code
      end

      def doc
        @doc ||= Nokogiri::XML body
      end

      def xml_result
        parser.parse(doc.at_xpath("//return").to_s).fetch( :return, {}).tap do |hash|
          hash[:detail_output].tap {|r| r[:amount] = r[:amount].to_i }

          hash.each { |k, v| hash.store(k, OpenStruct.new(v)) if v.is_a?(Hash) }
        end
      end

      def xml_error
        doc.xpath("//faultstring")
      end

      def errors_display
        errors.join ', '
      end

      def valid?
        errors.empty?
      end

      def signed_node
        doc.at_xpath '//ds:SignedInfo', {'ds' => 'http://www.w3.org/2000/09/xmldsig#'}
      end

      def signature_node
        doc.at_xpath('//ds:SignatureValue', {'ds' => 'http://www.w3.org/2000/09/xmldsig#'})
      end

      def signature_decode
        Base64.decode64(signature_node.content)
      end

      def response_code
        @response_code ||= doc.xpath("//responseCode").text
      end

      def response_code_display
        if response_code.present?
          RESPONSE_CODE.fetch(action, RESPONSE_CODE[:default]).fetch(response_code, response_code)
        end
      end

      def inspect
        result = ["valid: #{valid?}"]
        result << attributes_display if attributes.any?
        result << "error: \"#{errors_display}\"" if errors.any?
        "#<#{self.class} #{result.join(', ')} >"
      end

      def exception?
        false
      end

      def exception
        nil
      end

      def method_missing(method_name, *args, &block)
        attributes[method_name.to_sym] || super
      end

      def respond_to_missing?(method_name, include_private = false)
        attributes.keys.include?(method_name.to_sym) || super
      end

      def xml_error_display
        xml_error.map { |e| e.text.gsub(/<!--|-->/, '').strip }
      end

      private

      def verify
        return if signature_node.nil?

        signed_node.add_namespace 'soap', 'http://schemas.xmlsoap.org/soap/envelope/'
        signed_node_canonicalize = signed_node.canonicalize Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, ["soap"], nil

        pub_key.verify OpenSSL::Digest::SHA1.new, signature_decode, signed_node_canonicalize
      end

      def server_cert
        @server_cert ||= begin
          path = Transbank::Webpay.configuration.server_cert_path
          OpenSSL::X509::Certificate.new File.read(path)
        end
      end

      def pub_key
        server_cert.public_key
      end

      def parser
        @parser ||= Nori.new convert_tags_to: lambda { |tag| tag.snakecase.to_sym }
      end

      def attributes_display
        attributes.map{|name, value| "#{name}: \"#{value}\""}.join ', '
      end

      def validate!
        if response_code.present? and response_code != '0'
          self.errors << response_code_display
        end

        if content.class != Net::HTTPOK
          self.errors += xml_error_display
          self.errors << content.message if content.respond_to?(:message) and self.errors.blank?
        end

        if (self.errors.blank? || signature_node.present?) && !verify
          raise Exceptions::InvalidSignature.new("Invalid signature")
        end
      end
    end
  end
end
# rubocop:enable all