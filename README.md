# Deprecation Notice:
This SDK is deprecated. For alternatives, please visit [•tbk. | DEVELOPERS - Documentación](https://www.transbankdevelopers.cl/documentacion/oneclick#crear-una-inscripcion)

# Transbank::Webpay

Ruby Implementation of Transbank Webpay API SOAP

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'transbank-webpay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install transbank-webpay

Run the generator:

    $ rails generate transbank_webpay:install

## Usage

**Init Transaction**

```ruby
response = Transbank::Webpay.init_transaction({
  buy_order:  'A1234567',
  session_id: '123456',
  return_url: 'http://web.com/return',
  final_url:  'http://web.com/finalize',
  amount:     12_000
})
 => #<Transbank::Webpay::Response valid: true, #<Transbank::Webpay::Struct token="12333b5bcd772565db2cbf36e88eafcca93a95dad29dd8bd6f44d6d37345", url="https://tbk-web.com/initTransactioninitTransaction">>
response.token
=> "12333b5bcd772565db2cbf36e88eafcca93a95dad29dd8bd6f44d6d37345"
response.url
=> "https://tbk-web.com/initTransaction"
response.valid?
=> true
```

**Get Transaction Result**

```ruby
response = Transbank::Webpay.get_transaction_result(token)
=> #<Transbank::Webpay::Response valid: true, #<Transbank::Webpay::Struct accounting_date="0234", buy_order="A1234567", card_detail=#<Transbank::Webpay::Struct card_number=3456>, detail_output=#<Transbank::Webpay::Struct shares_number=0, amount=12000, commerce_code=237020000556, buy_order="A1234567", authorization_code=1234, payment_type_code="VN", response_code=0>, session_id=123456, transaction_date=Mon, 10 Jul 2016 10:00:00 -0400, url_redirection="https://tbk-web.com/filtroUnificado/voucher.cgi", vci="TSY">>
response.accounting_date
=> "0234"
response.buy_order
=> "A1234567"
response.card_detail.card_number
=> 3456
response.detail_output.shares_number
=> 0
response.detail_output.amount
=> 12000
response.detail_output.commerce_code
=> 237020000556
response.detail_output.buy_order
=> "A1234567"
response.detail_output.authorization_code
=> 1234
response.detail_output.payment_type_code
=> "VN"
response.response_code
=> 0
response.session_id
=> 123456
response.transaction_date
=> Mon, 10 Jul 2016 10:00:00 -0400
response.url_redirection
=> "https://tbk-web.com/filtroUnificado/voucher.cgi"
response.vci
=> "TSY"
response.valid?
=> true
```

**Acknowledge Transaction**

```ruby
response = Transbank::Webpay.acknowledge_transaction(token)
=> #< Transbank::Webpay::Response valid: true>
response.valid?
=> true
```

**Nullify**

```ruby
Transbank::Webpay.nullify({
  authorization_code: 1234,
  authorized_amount: 12_000,
  buy_order: 'A1234567',
  nullify_amount: 12_000
})
=> #<Transbank::Webpay::Response valid: true, #<Transbank::Webpay::Struct authorization_code=1415234, authorization_date=Mon, 10 Jul 2016 10:00:00 -0400, balance=0, nullified_amount=12000, token="8743gr557f7037005a48487197b0539a021436dabaf485c4947c95347ba1dgdw78">>

response.authorization_code
=> 1415234
response.authorization_date
=> Mon, 10 Jul 2016 10:00:00 -0400
response.balance
=> 0
response.nullified_amount
=> 12000
response.token
=> "8743gr557f7037005a48487197b0539a021436dabaf485c4947c95347ba1dgdw78"
response.valid?
=> true
```
**Available response methods:**


```ruby
response.valid? # true or false if any errors occurred (exceptions included)
response.errors # errors array
response.errors_display? # errors for human
response.exception? # true or false if an exception occurred
response.exception # exception object
response.attributes # hash attributes response (token, reverse_code . . .)
```

## Configuration

First, you need to set up your configuration:

`rails generate transbank_webpay:install`

Then edit (config/initializers/transbank_webpay.rb):

```ruby
Transbank::Webpay.configure do |config|
  config.wsdl_transaction_url = 'WEBPAY_SOAP_URL'
  config.wsdl_nullify_url     = 'NULLIFY_WEBPAY_SOAP_URL'
  config.cert_path            = 'ABSOLUTE_PATH_TO_CRT_FILE'
  config.key_path             = 'ABSOLUTE_PATH_TO_KEY_FILE'
  config.server_cert_path     = 'ABSOLUTE_PATH_TO_SERVER_CRT_OR_PEM_FILE'
  config.commerce_code        = 'COMMERCE_CODE'
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/transbank-webpay/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

transbank-webpay is released under the [MIT License](http://www.opensource.org/licenses/MIT).
