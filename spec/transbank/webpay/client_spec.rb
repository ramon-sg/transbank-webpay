require 'spec_helper'

describe Transbank::Webpay::Client do
  before(:all) do
    Transbank::Webpay.configure do |config|
      config.http_options = { read_timeout: 55, open_timeout: 55 }
    end
  end

  let(:client) do
    described_class.new 'https://transbank-example.cl/oneclick'
  end

  describe 'check default options' do
    it { expect(client.http.use_ssl?).to be(true) }
    it { expect(client.http.verify_mode).to eq(OpenSSL::SSL::VERIFY_NONE) }
  end

  describe 'check options' do
    it { expect(client.http.read_timeout).to eq(55) }
    it { expect(client.http.open_timeout).to eq(55) }
  end

  describe '#post' do
    let(:headers) do
      {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Content-Type' => 'application/soap+xml; charset=utf-8',
        'User-Agent' => 'Ruby'
      }
    end

    it 'init incription' do
      stub_request(:post, 'https://transbank-example.cl/oneclick')
        .with(body: '<xml></xml>', headers: headers)
        .to_return(status: 200, body: "", headers: {})

      expect(client.post('<xml></xml>').code).to eq('200')
    end
  end
end
