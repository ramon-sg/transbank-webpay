require 'spec_helper'

RSpec.describe Transbank::Webpay::Helper do
  let(:subject) { Object.new.extend described_class }

  describe '#underscore' do
    it { expect(subject.underscore('userId')).to eq('user_id') }
    it { expect(subject.underscore('userId')).to eq('user_id') }
  end

  describe '#typecasting' do
    it { expect(subject.typecasting('true')).to eq(true) }
    it { expect(subject.typecasting('false')).to eq(false) }
    it { expect(subject.typecasting('1')).to eq(1) }
    it { expect(subject.typecasting('01')).to eq('01') }
    it { expect(subject.typecasting('2016-01-10T10:10:00.000-04:00')).to be_a(DateTime) }
  end

  describe '#xml_to_hash' do
    context 'init transaction' do
      it 'returns hash' do
        xml = params_xml('init_transaction/response_unsigned.xml')
        result = subject.xml_to_hash(xml)
        expect(result.token).to eq('e7145059e217109b7e31182d0dc7ee53c91022f8e5de055fe52e5b9069c627e2')
        expect(result.url).to eq('https://tbk.dev/initTransaction')
      end
    end

    context 'init transaction' do
      it 'returns hash' do
        xml = params_xml('get_transaction_result/response_unsigned.xml')
        result = subject.xml_to_hash(xml)
        expect(result.accounting_date).to eq('0777')
        expect(result.buy_order).to eq('T12E42079B50157T26')
        expect(result.card_detail.card_number).to eq(7676)

        expect(result.detail_output.shares_number).to eq(0)
        expect(result.detail_output.amount).to eq(6_000)
        expect(result.detail_output.commerce_code).to eq(876_020_000_001)
        expect(result.detail_output.buy_order).to eq('T12E42079B50157T26')
        expect(result.detail_output.authorization_code).to eq(1234)
        expect(result.detail_output.payment_type_code).to eq('VN')
        expect(result.detail_output.response_code).to eq(0)

        expect(result.session_id).to eq(50_160_716_200_736)
        expect(result.transaction_date).to be_a(DateTime)
        expect(result.url_redirection).to eq('https://tbk.dev/voucher.cgi')
        expect(result.vci).to eq('TSY')
      end
    end

    context 'init transaction' do
      it 'returns hash' do
        xml = params_xml('acknowledge_transaction/response_unsigned.xml')
        result = subject.xml_to_hash(xml)
        expect(result.to_h).to eq({})
      end
    end
  end

  def params_xml(xml_path)
    xml = open_xml(xml_path)
    doc = Nokogiri::XML(xml)
    doc.at_xpath("//return").to_s
  end
end
