module Transbank
  module Webpay
    module Params
      def build_init_transaction_params(underscore_params = {})
        camelcase_params = {
          wSTransactionType: 'TR_NORMAL_WS',
          buyOrder: underscore_params[:buy_order],
          sessionId: underscore_params[:session_id],
          returnURL: underscore_params[:return_url],
          finalURL: underscore_params[:final_url],
          transactionDetails: {
            amount: underscore_params[:amount],
            commerceCode: Transbank::Webpay.configuration.commerce_code,
            buyOrder: underscore_params[:buy_order]
          }
        }

        { wsInitTransactionInput: camelcase_params }
      end
    end
  end
end
