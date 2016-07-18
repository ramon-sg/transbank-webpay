require 'spec_helper'

RSpec.describe Transbank::Webpay::Reader do
  let(:subject_class) do
    Class.new do
      include Transbank::Webpay::Reader

      def initialize(params = {})
        @action = params.delete(:action)
        @content = OpenStruct.new params
      end
    end
  end

  subject { subject_class.new }

  describe '#xml_error_display' do
    it 'returns xml error for humans' do
      subject = new_subject 'nullify/transaction_not_found.xml'
      expect(subject.xml_error_display).to eq(['Transaction not found(274)'])
    end
  end

  describe '#attributes?' do
    context 'without attributes' do
      subject { new_subject 'acknowledge_transaction/response_unsigned.xml' }
      it { expect(subject.attributes?).to be(false) }
    end

    context 'with attributes' do
      subject { new_subject 'init_transaction/response_unsigned.xml' }
      it { expect(subject.attributes?).to be(true) }
    end
  end

  describe 'response_code_display' do
    context 'with response_code -1' do
      subject do
        xml_path = 'get_transaction_result/response_unsigned_response_code_-1.xml'
        new_subject xml_path, :get_transaction_result
      end
      it { expect(subject.response_code_display).to eq('rechazo de transacción') }
    end

    context 'with response_code 0' do
      subject do
        xml_path = 'get_transaction_result/response_unsigned.xml'
        new_subject xml_path, :get_transaction_result
      end
      it { expect(subject.response_code_display).to eq('transacción aprobada') }
    end
    context 'default action' do
      context 'with response_code 0' do
        subject do
          xml_path = 'get_transaction_result/response_unsigned.xml'
          new_subject xml_path, :get_transaction_result_not
        end
        it { expect(subject.response_code_display).to eq('aprobada') }
      end
    end
  end
end
