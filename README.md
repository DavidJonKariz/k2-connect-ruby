# DISCLAIMER!!

The following library has not yet been finalised to production, and as such, neither consumable or usable as a gem/ruby library.

# K2ConnectRuby For Rails

Ruby SDK for connection to the Kopo Kopo API.
This documentation gives you the specifications for connecting your systems to the Kopo Kopo Application.
Primarily you can connect to the Kopo Kopo system to perform the following:

 - Receive Webhook notifications.
 - Receive payments from your users/customers.
 - Initiate payments to third parties.
 - Initiate transfers to your settlement accounts.
 
The library is optimized for **Rails Based Frameworks**.
Please note, all requests MUST be made over HTTPS.
Any non-secure requests are met with a redirect (HTTP 302) to the HTTPS equivalent URI.
All calls made without authentication will also fail.

## Installation

Add this line to your application's Gemfile:

    gem 'k2-connect-ruby'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install k2-connect-ruby

## Usage

Initially, you add the require line:

    require 'k2-connect-ruby'

### Authentication

In order to request for application authorization we need to execute the client credentials flow, this is done so by having your application server make a HTTPS request to the Kopo Kopo authorization server, through the K2Subscribe class.

Create an Object of the K2Subscription class, passing an event-type parameter, used to differentiate which Webhook Subscription you are identifying, together with the webhook secret.

 - For Buygoods Transaction Received


    buygoods_received = K2ConnectRuby::K2Subscribe.new('buygoods_transaction_received', webhook_secret)


- For Buygoods Transaction Reversed


    buygoods_reversed = K2ConnectRuby::K2Subscribe.new('buygoods_transaction_reversed', webhook_secret)


 - For Customer Created


    customer_create = K2ConnectRuby::K2Subscribe.new('customer_created', webhook_secret)


 - For Settlement Transfer Completed


    settlement_transfer = K2ConnectRuby::K2Subscribe.new('settlement_transfer_completed', webhook_secret)


Next is to request for the token, done through the recently created K2Subscribe Object. From here you will pass in your client_id and client_secret details.

    buygoods_received.token_request('CLIENT_ID', 'CLIENT_SECRET')
 
 The Access Token that is returned is stored within the Object, accessible under the local variable 'access_token' of the Object.
 
    your_access_token = buygoods_received.access_token
 
 ##### Remember to store highly sensitive information or core details like the client_id, client_secret, access_token and such, in a config file, while ensuring to indicate them in your .gitignore file, to avoid publicly uploading them to Github.

Next, we formally create the webhook subscription by calling on the following method:

    buygoods_reversed.webhook_subscribe
 
 The event-type parameter specified during creating the K2Subscription Object will be used to specify what event type we intend to use.
 
 
 ### STK-Push
 
 To receive payments from M-PESA users via STK Push we first create a K2Stk Object, passing the access_token that was created prior.
 
    k2_stk = K2ConnectRuby::K2Stk.new(your_access_token)
  
 - Afterwards we send a POST request for receiving Payments by calling the following method and passing the params value received from the POST Form Request:
  

    k2_stk.receive_mpesa_payments(params)
    
    
One can also pass the following Hash Object instead of the Rails Form params:

    {first_name: "your_first_name", last_name: "your_last_name", phone: "your_phone_number", email: "your_email", currency: "your_currency", value: "your_value"}

A Successful Response will be received containing the URL of the Payment Location.

 - To Query the STK Payment Request Status pass the reference number or id to the following method as shown:


    k2_stk.query_status(params)
    
    
One can also pass the following Hash Object instead of params:

    {id: "your_id"}


As a result a JSON payload will be returned, accessible with the k2_response_body variable.

### PAY

First Create the K2Pay Object passing the access token


    k2_pay = K2ConnectRuby::K2Pay.new(access_token)


 - To Add PAY Recipients, a request is sent by calling:
  

    k2_pay.pay_recipients(params)
    

One can also pass the following Hash Object instead of params:

    {first_name: "your_first_name", last_name: "your_last_name", phone: "your_phone_number", email: "your_email", currency: "your_currency", value: "your_value", network: "network", pay_type: "mobile_wallet", account_name: "account_name", bank_id: "bank_id", bank_branch_id: "bank_branch_id", account_number: "account_number"}
    
The pay_type value can either be `mobile_wallet` or `bank_account`

The Params are passed as the argument containing all the form data sent. A Successful Response is returned with the URL of the recipient resource in the HTTP Location Header.

 - To Create Outgoing PAYment to a third party.


    k2_pay.create_payment(params)
    
    
Or can also pass the following Hash Object instead of params:

    {currency: "currency", value: "value", }

The Params are passed as the argument containing all the form data sent. A Successful Response is returned with the URL of the Payment resource in the HTTP Location Header.

 - To Query the PAYment Request Status pass the reference number or payment_id to the following method as shown:


    k2_pay.query_status(params)
    
    
Or can also pass the following Hash Object instead of params:

    {id: "your_id"}

As a result a JSON payload will be returned, accessible with the k2_response_body variable.

### Transfers

This will Enable one to transfer funds to your pre-approved settlement accounts.

First Create the K2Transfer Object

    k2_transfers = K2ConnectRuby::K2Transfer.new(access_token)

 - Create a Verified Settlement Account through the following method:
  
  
    k2_transfers.settlement_account(params)
    
    
One can also pass the following Hash Object instead of params:

    {account_name: "account_name", bank_ref: "bank_ref", bank_branch_ref: "bank_branch_ref", account_number: "account_number"}

The Params are passed as the argument having all the form data. A Successful Response is returned with the URL of the merchant bank account in the HTTP Location Header.

 - To Create Transfer Request, one can either have it `blind`, meaning that it has no specified destination with the default/specified settlement account being selected, 
or one can have a `targeted` transfer with a specified settlement account in mind. Either can be done through:

 - For a **Blind** Transfer:


     k2_transfers.transfer_funds(nil, params)


With `nil` representing that there are no specified destinations.

- For a **Target** Transfer:


     k2_transfers.transfer_funds(params[:target], params)
     
     
Or can also pass the following Hash Object instead of params for either **Blind** or **Targeted** Transfer:

    {currency: "currency", value: "value", }

The Params are passed as the argument containing all the form data sent. A Successful Response is returned with the URL of the Transfer in the HTTP Location Header.

 - To Query the status of the prior initiated Transfer Request pass the reference number or payment_id to the following method as shown:


     k2_transfers.query_status(params)
     
     
Or can also pass the following Hash Object instead of params:

    {id: "your_id"}

A HTTP Response will be returned in a JSON Payload, accessible with the k2_response_body variable.

### Parsing the JSON Payload

The K2Client class will be use to parse the Payload received from Kopo Kopo, and to further consume the webhooks and split the responses into components, the K2Authenticator and
K2SplitRequest Classes will be used.

 - First Create an Object of the K2Client class to Parse the response, passing the client_secret_key received from Kopo Kopo:


     k2_parse = K2ConnectRuby::K2Client.new('K2_SECRET_KEY'])


##### Remember to have kept it safe in a config file, it is highly recommended so as to keep it safe. Also add that specific config file destination in your .gitignore.

 - Next, parse the request:


     k2_parse.parse_request(request)


 - Authenticating the Response to ensure it came from Kopo Kopo:


     K2Authenticator.authenticate(k2_parse.hash_body, k2_parse.api_secret_key, k2_parse.k2_signature)


 - Create a Hash Object to receive the hash components resulting from processing the parsed request results:


     k2_components = K2ProcessResult.process(k2_parse.hash_body)
     
     
 Below is a list of key symbols accessible for each of the Results retrieved after processing it into a Hash Object.
 
1. Buy Goods Transaction Received:
    - id
    - resource_id
    - topic
    - created_at
    - event
    - type
    - resource
    - reference
    - origination_time
    - msisdn
    - amount
    - currency
    - till_number
    - system
    - resource_status
    - first_name
    - middle_name
    - last_name
    - links
    - self
    - link_resource
    
2. Buy Goods Transaction Reversed. Has the same key symbols as Buy Goods Transaction Received, plus:
    - reversal_time 
    
3. Settlement Transfer:
    - id
    - resource_id
    - topic
    - created_at
    - event
    - type
    - resource
    - reference
    - origination_time
    - resource_status
    - transfer_time
    - transfer_type
    - amount
    - currency
    - status
    - destination
    - destination_type
    - msisdn
    - destination_mm_system
    - links
    - self
    - link_resource

4. Customer Created:
    - id
    - resource_id
    - topic
    - created_at
    - event
    - type
    - resource
    - first_name
    - middle_name
    - last_name
    - msisdn
    - links
    - self
    - link_resource
    
5. Process STK Push Payment Request Result
    - id
    - resource_id
    - topic
    - created_at
    - status
    - event
    - type
    - resource
    - reference
    - origination_time
    - msisdn
    - amount
    - currency
    - till_number
    - system
    - resource_status
    - first_name
    - middle_name
    - last_name
    - errors
    - metadata
    - customer_id
    - metadata_reference
    - notes
    - self
    - payment_request
    - link_resource

6. Process PAY Result
    - id
    - reference
    - origination_time
    - destination
    - amount
    - currency
    - value
    - metadata
    - customer_id
    - notes
    - links
    - self


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kopokopo/k2-connect-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the K2ConnectRuby project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kopokopo/k2-connect-ruby/blob/master/CODE_OF_CONDUCT.md).
