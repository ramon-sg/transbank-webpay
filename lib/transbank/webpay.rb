require 'net/https'
require 'uri'
require 'savon'
require 'signer'
require 'nori'
require 'ostruct'

require 'transbank/webpay/version'
require 'transbank/webpay/configuration'
require 'transbank/webpay/helper'
require 'transbank/webpay/exception_response'
require 'transbank/webpay/client'
require 'transbank/webpay/response'
require 'transbank/webpay/document'
require 'transbank/webpay/params'
require 'transbank/webpay/request'
require 'transbank/webpay/api'

module Transbank
  module Webpay
    class << self
      attr_accessor :configuration

      # Delegate api
      Api.instance_methods.each { |m| define_method(m) { |*args| api.send(m, *args) } }
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def self.api
      @api ||= Api.new
    end
  end
end
