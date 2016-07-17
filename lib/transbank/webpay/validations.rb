module Transbank
  module Webpay
    module Validations
      attr_reader :errors

      def errors_display
        errors.join ', '
      end

      def valid?
        errors.empty?
      end

      def validate_response!
        validate_response_code!
        validate_http_response!

        return if errors.any? || validate_document

        raise Transbank::Webpay::Exceptions::InvalidSignature, 'Invalid signature'
      end

      private

      def calculated_digest
        node = doc.at_xpath('//soap:Body')
        node_canonicalize = node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, nil, nil)
        digest = OpenSSL::Digest::SHA1.new.reset.digest(node_canonicalize)
        Base64.encode64(digest).strip
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

      # Validations
      def validate_response_code!
        return if response_code.blank?
        @errors << response_code_display if response_code != '0'
      end

      def validate_http_response!
        return if content.class == Net::HTTPOK

        @errors += xml_error_display
        @errors << content.message if content.respond_to?(:message) && @errors.blank?
      end

      def validate_document
        return false if signature_node.nil?
        validate_digest && validate_signature
      end

      def validate_signature
        signed_node_canonicalize = signed_node.canonicalize(
          Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, ["soap"], nil
        )

        pub_key.verify OpenSSL::Digest::SHA1.new, signature_decode, signed_node_canonicalize
      end

      def validate_digest
        calculated_digest == digest
      end
    end
  end
end
