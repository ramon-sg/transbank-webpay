module Transbank
  module Webpay
    module Helper
      def camelcase(underscore)
        underscore
          .to_s
          .gsub(/(?<=_)(\w)/) { Regexp.last_match[1].upcase }
          .gsub(/(?:_)(\w)/, '\1')
      end
    end
  end
end
