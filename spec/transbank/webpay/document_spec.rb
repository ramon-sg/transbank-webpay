require 'spec_helper'

RSpec.describe Transbank::Webpay::Document do
  context 'init_transaction' do
    let(:xml) { open_xml 'init_transaction/request_unsigned.xml' }
    let(:params) do
      hash = {
        wSTransactionType: 'TR_NORMAL_WS',
        buyOrder: 'D3BD392038A94CL30',
        sessionId: 20_160_717_203_428,
        returnURL: 'http://web.dev/verify',
        finalURL: 'http://web.dev/finalize',
        transactionDetails: {
          amount: 10_000,
          commerceCode: 111_020_000_333,
          buyOrder: 'D3BD392038A94CL3'
        }
      }

      { wsInitTransactionInput: hash }
    end

    subject { described_class.new(:init_transaction, params) }

    describe '#unsigned_xml' do
      it { expect(subject.unsigned_xml).to eq_xml(xml) }
    end

    describe '#signed_xml' do
      let(:signed_xml) { open_xml 'init_transaction/request_signed.xml' }
      it { expect(subject.signed_xml).to eq_xml(signed_xml) }
    end
  end

  context 'get_transaction_result' do
    let(:xml) { open_xml 'get_transaction_result/request_unsigned.xml' }
    let(:token) { 'e123b4d90adfde61427trw370961d6e58824429c40d90ae2fbe565c26c65Ccd4' }
    subject { described_class.new(:getTransactionResult, tokenInput: token) }

    describe '#unsigned_xml' do
      it { expect(subject.unsigned_xml).to eq_xml(xml) }
    end

    describe '#signed_xml' do
      let(:signed_xml) { open_xml 'get_transaction_result/request_signed.xml' }
      it { expect(subject.signed_xml).to eq_xml(signed_xml) }
    end
  end

  context 'acknowledge_transaction' do
    let(:xml) { open_xml 'acknowledge_transaction/request_unsigned.xml' }
    let(:token) { 'nxBdsbdSPixMZsIajOJWyg2OklTBcXXiW1rxnSpi9fCg1sMaxay4xWMuYV0fTUay' }
    subject { described_class.new(:acknowledgeTransaction, tokenInput: token) }

    describe '#unsigned_xml' do
      it { expect(subject.unsigned_xml).to eq_xml(xml) }
    end

    describe '#signed_xml' do
      let(:signed_xml) { open_xml 'acknowledge_transaction/request_signed.xml' }
      it { expect(subject.signed_xml).to eq_xml(signed_xml) }
    end
  end

  context 'nullify' do
    let(:xml) { open_xml 'nullify/request_unsigned.xml' }
    let(:params) do
      hash = {
        authorizationCode: 1234,
        authorizedAmount: 21_000,
        buyOrder: '33E6D9CC59332AT25',
        nullifyAmount: 21_000,
        commerceId: 197_320_000_333
      }

      { nullificationInput: hash }
    end

    subject { described_class.new(:nullify, params) }

    describe '#unsigned_xml' do
      it { expect(subject.unsigned_xml).to eq_xml(xml) }
    end

    describe '#signed_xml' do
      let(:signed_xml) { open_xml 'nullify/request_signed.xml' }
      it { expect(subject.signed_xml).to eq_xml(signed_xml) }
    end
  end
end
