module Transbank
  module Webpay
    module Helper
      XS_INTEGER = /^[-+]?[1-9]([0-9]*)?$|^0$/
      XS_DATE_TIME = /^-?\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?$/

      def camelcase(underscore)
        underscore
          .to_s
          .gsub(/(?<=_)(\w)/) { Regexp.last_match[1].upcase }
          .gsub(/(?:_)(\w)/, '\1')
      end

      def underscore(camelcase)
        camelcase
          .to_s
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end

      def typecasting(value)
        case value
        when 'true'
          true
        when 'false'
          false
        when XS_DATE_TIME
          try_to_convert(value) { |v| DateTime.parse(v) }
        when XS_INTEGER
          try_to_convert(value) { |v| Integer v }
        else
          value
        end
      end

      def xml_to_hash(xml_io)
        result = Nokogiri::XML(xml_io)
        xml_node_to_hash(result.root)
      end

      private

      def xml_node_to_hash(node)
        return Transbank::Webpay::Struct.new if node.nil?
        return node.content unless node.element?
        return if node.children.empty?

        hash = node.children.each_with_object({}) do |child, h|
          result = xml_node_to_hash(child)
          return result if return_result?(child)

          assin_values h, result, child
        end

        Transbank::Webpay::Struct.new hash
      end

      def return_result?(child)
        child.next_sibling.nil? && child.previous_sibling.nil?
      end

      def try_to_convert(value)
        yield value
      rescue ArgumentError
        value
      end

      def assin_values(hash, result, child)
        return if child.name == 'text'

        key = underscore(child.name).to_sym
        value = typecasting result
        hash.store key, value
      end
    end
  end
end
