require 'spec_helper'

module Transbank
  module Webpay
    describe ExceptionResponse do
      let(:error_message) { 'the scheme http does not accept registry part: :80 (or bad hostname?)' }
      let(:raise_error) { URI::InvalidURIError.new error_message }
      let(:params) { { token: '11111', url: 'http://www.web.cl' } }

      let(:exception_response) { ExceptionResponse.new raise_error, :init_transaction, params }

      it { expect(exception_response.valid?).to be(false) }
      it { expect(exception_response.errors).to include(error_message) }
      it { expect(exception_response.exception?).to be(true) }
      it { expect(exception_response.errors_display).to eq("URI::InvalidURIError, #{error_message}") }
      it { expect(exception_response.params).to eq(params) }

      it 'returns inspect string' do
        klass = 'Transbank::Webpay::ExceptionResponse'
        inspect = "#<#{klass}: valid: false, error: 'URI::InvalidURIError, #{error_message}' >"
        expect(exception_response.inspect).to eq(inspect)
      end
    end
  end
end
