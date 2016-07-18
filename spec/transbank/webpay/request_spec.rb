require 'spec_helper'

RSpec.describe Transbank::Webpay::Request do
  context 'init transaction' do
    let(:url) { 'https://dev.com:80/init_transaction' }

    context 'valid signature' do
      before(:each) do
        xml = open_xml('init_transaction/response_signed.xml')
        stub_request(:post, url).to_return(body: xml)
      end
      subject { described_class.new url, :init_transaction, {} }

      it { expect(subject.response).to be_a(Transbank::Webpay::Response) }
    end

    context 'invalid signature' do
      before(:each) do
        xml = open_xml('init_transaction/response_signed_with_invalid_signature.xml')
        stub_request(:post, url).to_return(body: xml)
      end

      subject { described_class.new url, :init_transaction, {} }

      it 'returns raise error' do
        exception = Transbank::Webpay::Exceptions::InvalidSignature
        expect { subject.response }.to raise_exception(exception)
      end
    end
  end
end
