require 'spec_helper'

RSpec.describe Transbank::Webpay::Response do
  describe '#attributes' do
    context 'init_transaction' do
      context 'valid signed' do
        subject { new_subject('init_transaction/response_signed.xml', :init_transaction, one: 1) }

        describe '#exception?' do
          it { expect(subject.exception?).to be(false) }
        end

        describe '#exception' do
          it { expect(subject.exception).to be(nil) }
        end

        describe '#params' do
          it { expect(subject.params).to eq(one: 1) }
        end

        describe '#action' do
          it { expect(subject.action).to eq(:init_transaction) }
        end

        it { expect(subject.valid?).to be(true) }

        it 'returns attributes' do
          token = 'e7145059e217109b7e31182d0dc7ee53c91022f8e5de055fe52e5b9069c627e2'
          url = 'https://tbk.dev/initTransaction'

          expect(subject.token).to eq(token)
          expect(subject.url).to eq(url)
        end
      end

      context 'invalid url' do
        subject do
          xml_path = 'init_transaction/response_invalid_url.xml'
          new_subject(xml_path, :init_transaction, one: 1)
        end

        describe '#exception?' do
          it { expect(subject.exception?).to be(false) }
        end

        describe '#exception' do
          it { expect(subject.exception).to be(nil) }
        end

        describe '#params' do
          it { expect(subject.params).to eq(one: 1) }
        end

        describe '#action' do
          it { expect(subject.action).to eq(:init_transaction) }
        end

        it { expect(subject.valid?).to be(false) }
      end

      context 'invalid url' do
        it 'returns exception' do
          xml_path = 'init_transaction/response_signed_with_invalid_signature.xml'
          invalid_signature_exception = Transbank::Webpay::Exceptions::InvalidSignature
          expect { new_subject(xml_path) }.to raise_exception(invalid_signature_exception)
        end
      end
    end
  end

  def new_subject(xml_path = nil, action = :action, params = {})
    body = xml_path.nil? ? '<xml></xml>' : open_xml(xml_path)
    content = OpenStruct.new body: body
    described_class.new content, action, params
  end
end
