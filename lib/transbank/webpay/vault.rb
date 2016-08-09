require 'benchmark'
module Transbank
  module Webpay
    class Vault
      class << self
        def cert
          @cert ||= OpenSSL::X509::Certificate.new open(Transbank::Webpay.configuration.cert_path)
        end

        def private_key
          @private_key ||= OpenSSL::PKey::RSA.new open(Transbank::Webpay.configuration.key_path)
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
      end
    end
  end
end
