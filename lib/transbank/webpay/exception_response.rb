module Transbank
  module Webpay
    class ExceptionResponse
      attr_reader :exception, :action, :params

      def initialize(exception, action, params)
        @exception = exception
        @action = action
        @params = params
      end

      def valid?
        false
      end

      def errors
        [exception.message]
      end

      def exception?
        true
      end

      def errors_display
        "#{exception.class}, #{exception.message}"
      end

      def inspect
        "#<#{self.class}: valid: false, error: '#{errors_display}' >"
      end
    end
  end
end
