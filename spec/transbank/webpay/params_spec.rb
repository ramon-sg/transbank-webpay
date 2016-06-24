require 'spec_helper'

RSpec.describe Transbank::Webpay::Params do
  let(:subject) { Object.new.extend described_class }

  describe '#build_init_transaction_params' do
    it 'returns camelcase params' do
      camelcase_params = {
        wsInitTransactionInput: {
          wSTransactionType: 'TR_NORMAL_WS',
          buyOrder: '0000012',
          sessionId: 'session_1',
          returnURL: 'http://app.com/check',
          finalURL: 'http://app.com/finalize',
          transactionDetails: {
            amount: 500_000,
            commerceCode: '457020000401',
            buyOrder: '0000012'
          }
        }
      }

      Transbank::Webpay.configure do |config|
        config.commerce_code = '457020000401'
      end

      underscore_params = {
        buy_order: '0000012',
        session_id: 'session_1',
        return_url: 'http://app.com/check',
        final_url: 'http://app.com/finalize',
        amount: 500_000
      }

      result = subject.build_init_transaction_params(underscore_params)
      expect(result).to eq(camelcase_params)
    end
  end
end
