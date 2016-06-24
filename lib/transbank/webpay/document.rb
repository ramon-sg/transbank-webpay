module Transbank
  module Webpay
    class Document
      attr_reader :unsigned_document, :unsigned_xml
      XML_HEADER = "<env:Header><wsse:Security xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' wsse:mustUnderstand='1'/></env:Header>".freeze # rubocop:disable LineLength
      SOAPENV = 'http://schemas.xmlsoap.org/soap/envelope/'.freeze

      def initialize(wsdl_url, action, params = {})
        client = Savon.client(wsdl: wsdl_url)
        xml = client.build_request(action, message: params).body

        @unsigned_document = Nokogiri::XML(xml)
      end

      def envelope
        @envelope ||= unsigned_document.at_xpath("//env:Envelope")
      end

      def to_xml
        document.to_xml(save_with: 0)
      end

      def document
        @document ||= Nokogiri::XML(signed_xml).tap do |signed_document|
          x509data = signed_document.at_xpath("//*[local-name()='X509Data']")
          new_data = x509data.clone
          new_data.set_attribute('xmlns:ds', 'http://www.w3.org/2000/09/xmldsig#')
          n = Nokogiri::XML::Node.new('wsse:SecurityTokenReference', signed_document)
          n.add_child(new_data)
          x509data.add_next_sibling(n)
        end
      end

      def signed_xml
        envelope.prepend_child(XML_HEADER)
        unsigned_xml = unsigned_document.to_s

        signer = Signer.new(unsigned_xml)
        signer.cert = cert
        signer.private_key = private_key

        signer.document.xpath('//soapenv:Body', soapenv: SOAPENV).each do |node|
          signer.digest!(node)
        end

        signer.sign!(:issuer_serial => true)
        signer.to_xml
      end

      def cert
        @cert ||= OpenSSL::X509::Certificate.new open(Transbank::Webpay.configuration.cert_path)
      end

      def private_key
        @private_key ||= OpenSSL::PKey::RSA.new open(Transbank::Webpay.configuration.key_path)
      end
    end
  end
end
