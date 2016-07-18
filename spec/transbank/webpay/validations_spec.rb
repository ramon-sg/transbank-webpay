require 'spec_helper'

RSpec.describe Transbank::Webpay::Validations do
  let(:subject_class) do
    Class.new do
      include Transbank::Webpay::Validations
      include Transbank::Webpay::Reader

      def initialize(params = {})
        @action = params.delete(:action)
        @content = OpenStruct.new params
        @errors = []
      end
    end
  end

  subject { subject_class.new }

  describe '#xml_error' do
    it 'returns xml errors' do
      subject = new_subject 'nullify/transaction_not_found.xml'

      faultstring = '<faultstring>&lt;!-- Transaction not found(274) --&gt;</faultstring>'
      expect(subject.send(:xml_error).to_s).to eq(faultstring)
    end
  end

  describe 'errors_display' do
    it 'returns errors for humans' do
      subject.instance_variable_set('@errors', ['error 1', 'errors 2'])
      expect(subject.errors_display).to eq('error 1, errors 2')
    end
  end

  describe '#valid?' do
    context 'with errors' do
      before(:each) { subject.instance_variable_set('@errors', ['error 1']) }
      it { expect(subject.valid?).to be(false) }
    end

    context 'without errors' do
      before(:each) { subject.instance_variable_set('@errors', []) }
      it { expect(subject.valid?).to be(true) }
    end
  end

  describe '#digest' do
    subject { new_subject 'init_transaction/response_signed.xml' }
    it { expect(subject.send(:digest)).to eq('nO6oBmG1jaJyqGmTKMQRWiERNDE=') }
  end

  describe '#calculated_digest' do
    subject { new_subject 'init_transaction/response_signed.xml' }
    it { expect(subject.send(:calculated_digest)).to eq('nO6oBmG1jaJyqGmTKMQRWiERNDE=') }
  end

  describe '#validate_digest' do
    context 'with valid digest' do
      subject { new_subject 'init_transaction/response_signed.xml' }
      it { expect(subject.send(:validate_digest)).to be(true) }
    end

    context 'with invalid digest' do
      subject { new_subject 'init_transaction/response_signed_with_invalid_digest.xml' }
      it { expect(subject.send(:validate_digest)).to be(false) }
    end
  end

  describe '#validate_signature' do
    context 'with valid signature' do
      subject { new_subject 'init_transaction/response_signed.xml' }
      it { expect(subject.send(:validate_signature)).to be(true) }
    end

    context 'with invalid signature' do
      subject { new_subject 'init_transaction/response_signed_with_invalid_signature.xml' }
      it { expect(subject.send(:validate_signature)).to be(false) }
    end
  end

  describe '#validate_response_code!' do
    context 'with response_conde 0' do
      subject { new_subject 'get_transaction_result/response_unsigned.xml' }

      it 'returns zero errors' do
        subject.send(:validate_response_code!)
        expect(subject.errors.length).to eq(0)
      end
    end

    context 'with response_conde = -1' do
      subject do
        xml_path = 'get_transaction_result/response_unsigned_response_code_-1.xml'
        new_subject xml_path, :get_transaction_result
      end

      it 'returns zero errors' do
        subject.send(:validate_response_code!)
        expect(subject.errors.length).to eq(1)
      end
    end
  end

  describe '#validate_http_response!' do
    context 'with xml_error_display' do
      before(:each) { allow(subject).to receive(:xml_error_display) { ['xml error!!!'] } }
      context 'with valid http response' do
        before(:each) do
          allow(subject.content).to receive(:class) { Net::HTTPOK }
          subject.send :validate_http_response!
        end

        it { expect(subject.errors.length).to eq(0) }
      end

      context 'with invalid http response' do
        before(:each) do
          allow(subject.content).to receive(:class) { Net::HTTPNotFound }
          subject.send :validate_http_response!
        end

        it { expect(subject.errors).to eq(['xml error!!!']) }
      end
    end

    context 'with message' do
      before(:each) do
        allow(subject.content).to receive(:message) { 'message error!!!' }
      end

      context 'with valid http response' do
        before(:each) do
          allow(subject.content).to receive(:class) { Net::HTTPOK }
          subject.send :validate_http_response!
        end

        it { expect(subject.errors.length).to eq(0) }
      end

      context 'with invalid http response' do
        before(:each) do
          allow(subject.content).to receive(:class) { Net::HTTPNotFound }
          subject.send :validate_http_response!
        end

        it { expect(subject.errors).to eq(['message error!!!']) }
      end
    end
  end

  describe '#validate_response' do
    context 'with response_code -1 ' do
      subject do
        xml_path = 'get_transaction_result/response_unsigned_response_code_-1.xml'
        new_subject xml_path, :get_transaction_result
      end
      before(:each) { subject.send(:validate_response!) }

      it { expect(subject.valid?).to be(false) }
    end

    context 'with unsigned xml' do
      subject do
        xml_path = 'get_transaction_result/response_unsigned.xml'
        new_subject xml_path, :get_transaction_result
      end

      it 'returns raise error' do
        exception = Transbank::Webpay::Exceptions::InvalidSignature
        expect { subject.send(:validate_response!) }.to raise_exception(exception)
      end
    end

    context 'with signed xml' do
      subject do
        xml_path = 'init_transaction/response_signed.xml'
        new_subject xml_path, :get_transaction_result
      end

      before(:each) { subject.send(:validate_response!) }

      it { expect(subject.valid?).to be(true) }
    end

    context 'acknowledge_transaction' do
      context 'with signed xml' do
        subject do
          xml_path = 'acknowledge_transaction/response_signed.xml'
          new_subject xml_path, :get_transaction_result
        end

        before(:each) { subject.send(:validate_response!) }

        it { expect(subject.valid?).to be(true) }
      end
    end

    context 'init_transaction' do
      context 'invalid url' do
        subject do
          xml_path = 'init_transaction/response_invalid_url.xml'
          new_subject xml_path, :init_transaction
        end

        before(:each) { subject.send(:validate_response!) }

        it { expect(subject.valid?).to be(false) }
        it { expect(subject.errors_display).to eq('Invalid return url(304)') }
      end
    end
  end

  describe '#validate_document' do
    context 'with valid xml' do
      subject { new_subject 'init_transaction/response_signed.xml' }
      it { expect(subject.send(:validate_document)).to be(true) }
    end

    context 'with unsigned xml' do
      subject { new_subject 'init_transaction/response_unsigned.xml' }
      it { expect(subject.send(:validate_document)).to be(false) }
    end
  end
end
