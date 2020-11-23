# Stark Bank Elixir SDK Beta

Welcome to the Stark Bank Elixir SDK! This tool is made for Elixir
developers who want to easily integrate with our API.
This SDK version is compatible with the Stark Bank API v2.

If you have no idea what Stark Bank is, check out our [website](https://www.StarkBank.com/)
and discover a world where receiving or making payments
is as easy as sending a text message to your client!

## Supported Elixir Versions

This library supports Elixir versions 1.9+.

## Stark Bank API documentation

Feel free to take a look at our [API docs](https://www.starkbank.com/docs/api).

## Versioning

This project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.

## Setup

### 1. Install our SDK

To install the package with mix, add this to your deps and run `mix deps.get`:

```elixir
def deps do
  [
    {:starkbank, "~> 2.1.0"}
  ]
end
```

### 2. Create your Private and Public Keys

We use ECDSA. That means you need to generate a secp256k1 private
key to sign your requests to our API, and register your public key
with us so we can validate those requests.

You can use one of following methods:

2.1. Check out the options in our [tutorial](https://starkbank.com/faq/how-to-create-ecdsa-keys).

2.2. Use our SDK:

```elixir
{private_key, public_key} = StarkBank.Key.create()

# or, to also save .pem files in a specific path
{private_key, public_key} = StarkBank.Key.create("file/keys/")
```

**Note**: When you are creating a new Project, it is recommended that you create the
keys inside the infrastructure that will use it, in order to avoid risky internet
transmissions of your **private-key**. Then you can export the **public-key** alone to the
computer where it will be used in the new Project creation.

### 3. Create a Project

You need a project for direct API integrations. To create one in Sandbox:

3.1. Log into [Starkbank Sandbox](https://sandbox.web.starkbank.com)

3.2. Go to Menu > Usuários (Users) > Projetos (Projects)

3.3. Create a Project: Give it a name and upload the public key you created in section 2.

3.4. After creating the Project, get its Project ID

3.5. Use the Project ID and private key to create the object below:

```elixir
# Get your private key from an environment variable or an encrypted database.
# This is only an example of a private key content. You should use your own key.
private_key_content = "
-----BEGIN EC PARAMETERS-----
BgUrgQQACg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMCwW74H6egQkTiz87WDvLNm7fK/cA+ctA2vg/bbHx3woAcGBSuBBAAK
oUQDQgAE0iaeEHEgr3oTbCfh8U2L+r7zoaeOX964xaAnND5jATGpD/tHec6Oe9U1
IF16ZoTVt1FzZ8WkYQ3XomRD4HS13A==
-----END EC PRIVATE KEY-----
"

user = StarkBank.project(
    id: "5671398416568321",
    environment: :sandbox,
    private_key: private_key_content
)
```

NOTE 1: Never hard-code your private key. Get it from an environment variable or an encrypted database.

NOTE 2: We support `'sandbox'` and `'production'` as environments.

NOTE 3: The project you created in `sandbox` does not exist in `production` and vice versa.


### 4. Setting up the user

There are two kinds of users that can access our API: **Project** and **Member**.

- `Member` is the one you use when you log into our webpage with your e-mail.
- `Project` is designed for integrations and is the one meant for our SDK.

There are two ways to inform the user to the SDK:
 
4.1 Passing the user as argument in all functions using the `user` keyword:

```elixir
balance = StarkBank.Balance.get!(user: user)
```

4.2 Set it as a default user in the `config/config.exs` file:

```elixir
import Config

config :starkbank,
  project: [
    environment: :sandbox,
    id: "9999999999999999",
    private_key: private_key_content
  ]
```

Just select the way of passing the project user that is more convenient to you.
On all following examples we will assume a default user has been set in the configs.


### 5. Setting up the error language

The error language can also be set in the `config/config.exs` file:

```elixir
import Config

config :starkbank,
  language: "en-US"
```

Language options are "en-US" for english and "pt-BR" for brazilian portuguese. English is default


## Testing in Sandbox

Your initial balance is zero. For many operations in Stark Bank, you'll need funds
in your account, which can be added to your balance by creating a Boleto.

In the Sandbox environment, 90% of the created Boletos will be automatically paid,
so there's nothing else you need to do to add funds to your account. Just create
a few and wait around a bit.

In Production, you (or one of your clients) will need to actually pay this Boleto
for the value to be credited to your account.


## Usage

Here are a few examples on how to use the SDK. If you have any doubts, use the built-in
`h()` function to get more info on the desired functionality
(for example: `StarkBank.Boleto |> h`)

**Note**: Almost all SDK functions also provide a bang (!) version. To simplify the examples, they will be used the most throughout this README.

### Get balance

To know how much money you have in your workspace, run:

```elixir
balance = StarkBank.Balance.get!()
IO.puts(balance.amount / 100)
```

### Create invoices

You can create dynamic QR Code invoices to charge customers or to receive money from accounts
you have in other banks.

```elixir
invoice = StarkBank.Invoice.create!(
  [
      %StarkBank.Invoice{
      amount: 400000,
      due: String.replace(DateTime.to_iso8601(DateTime.add(DateTime.utc_now), 30*24*60*60, :second)), "Z", "+00:00"),
      tax_id: "012.345.678-90",
      name: "Iron Bank S.A.",
      expiration: 123456789,
      fine: 2.5,
      interest: 1.3,
      discounts: [
        %{
          percentage: 10,
          due: String.replace(DateTime.to_iso8601(DateTime.add(DateTime.utc_now), 20*24*60*60, :second)), "Z", "+00:00")
        }
      ],
      tags: [
        "War supply",
        "Invoice #1234"
      ],
      descriptions: [
        %{
          key: "Field1",
          value: "Something"
        }
      ]
    }
  ]
) |> IO.inspect()
```

**Note**: Instead of using Invoice objects, you can also pass each invoice element in dictionary format

### Get an invoice

After its creation, information on an invoice may be retrieved by its id. 
Its status indicates whether it's been paid.

```elixir
invoice = StarkBank.Invoice.get!("6750458353811456")
  |> IO.inspect
```

### Get an invoice PDF

After its creation, an invoice PDF may be retrieved by its id. 

```elixir
pdf = StarkBank.Invoice.pdf!("6750458353811456", layout: "default")

file = File.open!("invoice.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

### Get an invoice QR Code 

After its creation, an invoice QR Code png file may be retrieved by its id. 

```elixir
qrcode = StarkBank.Invoice.qrcode!("5443064852119552")

file = File.open!("invoice.png", [:write])
IO.binwrite(file, qrcode)
File.close(file)
```

### Cancel an invoice

You can also cancel an invoice by its id.
Note that this is not possible if it has been paid already.

```elixir
invoice = StarkBank.Invoice.update!("6750458353811456", status: "canceled")
  |> IO.inspect
```

### Update an invoice

You can update an invoice's amount, due date and expiration by its id.
Note that this is not possible if it has been paid already.

```elixir
invoice = StarkBank.Invoice.update!(
  "6750458353811456", 
  amount: 123456, 
  due: String.replace(DateTime.to_iso8601(DateTime.add(DateTime.utc_now), 15*24*60*60, :second)), "Z", "+00:00"),
  expiration: 123456789
)
  |> IO.inspect
```

### Query invoices

You can get a list of created invoices given some filters.

```elixir
invoices = StarkBank.Invoice.query!(
  after: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  status: "overdue",
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

### Query invoice logs

Logs are pretty important to understand the life cycle of an invoice.

```elixir
for log <- StarkBank.Invoice.Log.query!(invoice_ids: ["6750458353811456"]) do
  log |> IO.inspect
end
```

### Get an invoice log

You can get a single log by its id.

```elixir
log = StarkBank.Invoice.Log.get!("6288576484474880")
  |> IO.inspect
```

### Create boletos

You can create boletos to charge customers or to receive money from accounts
you have in other banks.

```elixir
boletos = StarkBank.Boleto.create!(
  [
    %StarkBank.Boleto{
        amount: 23571,  # R$ 235,71
        name: "Buzz Aldrin",
        tax_id: "012.345.678-90",
        street_line_1: "Av. Paulista, 200",
        street_line_2: "10 andar",
        district: "Bela Vista",
        city: "São Paulo",
        state_code: "SP",
        zip_code: "01310-000",
        due: Date.utc_today |> Date.add(30),
        fine: 5,  # 5%
        interest: 2.5,  # 2.5% per month
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using Boleto structs, you can also pass each boleto element in map format

### Get boleto

After its creation, information on a boleto may be retrieved by passing its id.
Its status indicates whether it's been paid.

```elixir
boleto = StarkBank.Boleto.get!("6750458353811456")
  |> IO.inspect
```

### Get boleto PDF

After its creation, a boleto PDF may be retrieved by passing its id.

```elixir
pdf = StarkBank.Boleto.pdf!("6750458353811456", layout: "default")

file = File.open!("boleto.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

### Delete boleto

You can also cancel a boleto by its id.
Note that this is not possible if it has been processed already.

```elixir
boleto = StarkBank.Boleto.delete!("5202697619767296")
  |> IO.inspect
```

### Query boletos

You can get a stream of created boletos given some filters.

```elixir
boletos = StarkBank.Boleto.query!(
  after: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

### Query boleto logs

Logs are pretty important to understand the life cycle of a boleto.

```elixir
for log <- StarkBank.Boleto.Log.query!(boleto_ids: ["6750458353811456"]) do
  log |> IO.inspect
end
```

### Get a boleto log

You can get a single log by its id.

```elixir
log = StarkBank.Boleto.Log.get!("6288576484474880")
  |> IO.inspect
```

### Create transfers

You can also create transfers in the SDK (TED/DOC).

```elixir
transfers = StarkBank.Transfer.create!(
  [
    %StarkBank.Transfer{
        amount: 100,
        bank_code: "01",
        branch_code: "0001",
        account_number: "10000-0",
        tax_id: "012.345.678-90",
        name: "Tony Stark",
        tags: ["iron", "suit"]
    },
    %StarkBank.Transfer{
        amount: 200,
        bank_code: "341",
        branch_code: "1234",
        account_number: "123456-7",
        tax_id: "012.345.678-90",
        name: "Jon Snow",
        scheduled: Date.utc_today |> Date.add(3)
    }
]) |> IO.inspect
```

**Note**: Instead of using Transfer structs, you can also pass each transfer element in map format

### Query transfers

You can query multiple transfers according to filters.

```elixir
for transfer <- StarkBank.Transfer.query!(
  after: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  limit: 10
) do
  transfer |> IO.inspect
end
```

### Get transfer

To get a single transfer by its id, run:

```elixir
transfer = StarkBank.Transfer.get!("4882890932355072")
  |> IO.inspect
```

### Cancel transfer

To cancel a single scheduled transfer by its id, run:

```elixir
transfer = StarkBank.Transfer.delete!("4882890932355072")
  |> IO.inspect
```

### Get transfer PDF

A transfer PDF may also be retrieved by passing its id.
This operation is only valid for transfers with "processing" or "success" status.

```elixir
pdf = StarkBank.Transfer.pdf!("4882890932355072")

file = File.open!("transfer.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

### Query transfer logs

You can query transfer logs to better understand transfer life cycles.

```elixir
logs = StarkBank.Transfer.Log.query!(limit: 50)
  |> Enum.take(50)
  |> IO.inspect
```

### Get a transfer log

You can also get a specific log by its id.

```elixir
log = StarkBank.Transfer.Log.get!("6610264099127296")
  |> IO.inspect
```

### Pay a boleto

Paying a boleto is also simple.

```elixir
payments = StarkBank.BoletoPayment.create!(
  [
    %StarkBank.BoletoPayment{
        line: "34191.09008 64694.017308 71444.640008 1 96610000014500",
        tax_id: "012.345.678-90",
        scheduled: Date.utc_today |> Date.add(10),
        description: "take my money",
        tags: ["take", "my", "money"],
    },
    %StarkBank.BoletoPayment{
        bar_code: "34191972300000289001090064694197307144464000",
        tax_id: "012.345.678-90",
        scheduled: Date.utc_today |> Date.add(40),
        description: "take my money one more time",
        tags: ["again"],
    },
  ]
) |> IO.inspect
```

**Note**: Instead of using BoletoPayment structs, you can also pass each payment element in map format

### Get boleto payment

To get a single boleto payment by its id, run:

```elixir
payment = StarkBank.BoletoPayment.get!("5629412477239296")
  |> IO.inspect
```

### Get boleto payment PDF

After its creation, a boleto payment PDF may be retrieved by passing its id.

```elixir
pdf = StarkBank.BoletoPayment.pdf!("5629412477239296")

file = File.open!("boleto-payment.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

### Delete boleto payment

You can also cancel a boleto payment by its id.
Note that this is not possible if it has been processed already.

```elixir
payment = StarkBank.BoletoPayment.delete!("5629412477239296")
  |> IO.inspect
```

### Query boleto payments

You can search for boleto payments using filters.

```elixir
payments = StarkBank.BoletoPayment.query!(
  tags: ["company_1", "company_2"]
) |> Enum.take(10) |> IO.inspect
```

### Query boleto payment logs

Searches are also possible with boleto payment logs:

```elixir
for log <- StarkBank.BoletoPayment.Log.query!(
  payment_ids: ["5629412477239296", "5199478290120704"],
) do
  log |> IO.inspect
end
```

### Get boleto payment log

You can also get a boleto payment log by specifying its id.

```elixir
log = StarkBank.BoletoPayment.Log.get!("5391671273455616")
  |> IO.inspect
```

### Investigate a boleto

You can discover if a StarkBank boleto has been recently paid before we receive the response on the next day.
This can be done by creating a BoletoHolmes object, which fetches the updated status of the corresponding
Boleto object according to CIP to check, for example, whether it is still payable or not.

```elixir
holmes = StarkBank.BoletoHolmes.create!(
  [
    %StarkBank.BoletoHolmes{
        boleto_id: "5656565656565656"
    },
    %StarkBank.BoletoHolmes{
        boleto_id: "4848484848484848",
        tags: ["elementary", "my", "dear", "watson"]
    },
  ]
) |> IO.inspect
```

**Note**: Instead of using BoletoHolmes structs, you can also pass each payment element in map format

### Get boleto holmes

To get a single Holmes by its id, run:

```elixir
sherlock = StarkBank.BoletoHolmes.get!("5629412477239296")
  |> IO.inspect
```

### Query boleto holmes

You can search for boleto Holmes using filters.

```elixir
for sherlock <- StarkBank.BoletoHolmes.query!(
  tags: ["#123", "test"],
) do
  sherlock |> IO.inspect
end
```

### Query boleto holmes logs

Searches are also possible with boleto holmes logs:

```elixir
for log <- StarkBank.BoletoHolmes.Log.query!(
  holmes_ids: ["5629412477239296", "5199478290120704"],
) do
  log |> IO.inspect
end
```

### Get boleto holmes log

You can also get a boleto holmes log by specifying its id.

```elixir
log = StarkBank.BoletoHolmes.Log.get!("5391671273455616")
  |> IO.inspect
```

### Create utility payment

It's also simple to pay utility bills (such as electricity and water bills) in the SDK.

```elixir
payments = StarkBank.UtilityPayment.create!(
  [
    %StarkBank.UtilityPayment{
        bar_code: "83600000001522801380037107172881100021296561",
        scheduled: Date.utc_today |> Date.add(2),
        description: "paying some bills",
        tags: ["take", "my", "money"],
    },
    %StarkBank.UtilityPayment{
        line: "83680000001 7 08430138003 0 71070987611 8 00041351685 7",
        scheduled: Date.utc_today |> Date.add(3),
        description: "never ending bills",
        tags: ["again"],
    },
  ]
) |> IO.inspect
```

**Note**: Instead of using UtilityPayment structs, you can also pass each payment element in map format

### Query utility payments

To search for utility payments using filters, run:

```elixir
payments = StarkBank.UtilityPayment.query!(
  tags: ["electricity", "gas"]
) |> Enum.take(10) |> IO.inspect
```

### Get utility payment

You can get a specific bill by its id:

```elixir
payment = StarkBank.UtilityPayment.get!("6619425641857024")
  |> IO.inspect
```

### Get utility payment PDF

After its creation, a utility payment PDF may also be retrieved by passing its id.

```elixir
pdf = StarkBank.UtilityPayment.pdf!("6619425641857024")

file = File.open!("utility-payment.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

### Delete utility payment

You can also cancel a utility payment by its id.
Note that this is not possible if it has been processed already.

```elixir
payment = StarkBank.UtilityPayment.delete!("6619425641857024")
  |> IO.inspect
```

### Query utility bill payment logs

You can search for payments by specifying filters. Use this to understand the
bills life cycles.

```elixir
for log <- StarkBank.UtilityPayment.Log.query!(
  payment_ids: ["6619425641857024", "5738969660653568"]
) do
  log |> IO.inspect
end
```

### Get utility bill payment log

If you want to get a specific payment log by its id, just run:

```elixir
log = StarkBank.UtilityPayment.Log.get!("6197807794880512")
  |> IO.inspect
```

### Create transactions

To send money between Stark Bank accounts, you can create transactions:

```elixir
transactions = StarkBank.Transaction.create!(
  [
    %StarkBank.Transaction{
        amount: 100,  # (R$ 1.00)
        receiver_id: "5768064935133184",
        description: "Transaction to dear provider",
        external_id: "12345",  # so we can block anything you send twice by mistake
        tags: ["provider"]
    },
    %StarkBank.Transaction{
        amount: 234,  # (R$ 2.34)
        receiver_id: "5768064935133184",
        description: "Transaction to the other provider",
        external_id: "12346",  # so we can block anything you send twice by mistake
        tags: ["provider"]
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using Transaction structs, you can also pass each transaction element in map format

### Query transactions

To understand your balance changes (bank statement), you can query
transactions. Note that our system creates transactions for you when
you receive boleto payments, pay a bill or make transfers, for example.

```elixir
transactions = StarkBank.Transaction.query!(
  after: "2020-03-20",
  before: "2020-03-30"
) |> Enum.take(10) |> IO.inspect
```

### Get transaction

You can get a specific transaction by its id:

```elixir
transaction = StarkBank.Transaction.get!("6677396233125888")
  |> IO.inspect
```

### Create payment requests to be approved by authorized people in a cost center 

You can also request payments that must pass through a specific cost center approval flow to be executed.
In certain structures, this allows double checks for cash-outs and also gives time to load your account
with the required amount before the payments take place.
The approvals can be granted at our website and must be performed according to the rules
specified in the cost center.

**Note**: The value of the center\_id parameter can be consulted by logging into our website and going
to the desired cost center page.

```elixir
requests = StarkBank.PaymentRequest.create!(
  [
    %StarkBank.PaymentRequest{
        center_id: "5967314465849344",
        due: Date.utc_today |> Date.add(30),
        payment: %StarkBank.Transfer{
            amount: 100,
            bank_code: "01",
            branch_code: "0001",
            account_number: "10000-0",
            tax_id: "012.345.678-90",
            name: "Tony Stark",
        },
        tags: ["iron", "suit"],
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using PaymentRequest structs, you can also pass each payment request element in map format


### Query payment requests

To search for payment requests, run:

```elixir
requests = StarkBank.PaymentRequest.query!(
  center_id: "5967314465849344",
  after: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

### Create webhook subscription

To create a webhook subscription and be notified whenever an event occurs, run:

```elixir
webhook = StarkBank.Webhook.create!(
  url: "https://webhook.site/dd784f26-1d6a-4ca6-81cb-fda0267761ec",
  subscriptions: ["transfer", "boleto", "boleto-payment", "utility-payment"]
) |> IO.inspect
```

### Query webhooks

To search for registered webhooks, run:

```elixir
for webhook <- StarkBank.Webhook.query!() do
  webhook |> IO.inspect
end
```

### Get webhook

You can get a specific webhook by its id.

```elixir
webhook = StarkBank.Webhook.get!("6178044066660352")
  |> IO.inspect
```

### Delete webhook

You can also delete a specific webhook by its id.

```elixir
webhook = StarkBank.Webhook.delete!("6178044066660352")
  |> IO.inspect
```

### Process webhook events

It's easy to process events that have arrived in your webhook. Remember to pass the
signature header so the SDK can make sure it's really StarkBank that has sent you
the event.

```elixir
response = listen()  # this is the function you made to get the events posted to your webhook

{event, cache_pid} = StarkBank.Event.parse!(
  content: response.content,
  signature: response.headers["Digital-Signature"]
) |> IO.inspect
```

To avoid making unnecessary requests to the API (/GET public-key), you can pass the `cache_pid` (returned on all requests)
on your next parse. The process referred by the PID `cache_pid` will store the latest Stark Bank public key
and automatically refresh it if an inconsistency is found between the content, signature and current public key.

**Note**: If you don't send the cache_pid to the parser, a new cache process will be generated.

```elixir
{event, _cache_pid} = StarkBank.Event.parse!(
  content: response.content,
  signature: response.headers["Digital-Signature"],
  cache_pid: cache_pid
) |> IO.inspect
```

If the data does not check out with the Stark Bank public-key, the function will automatically request the
key from the API and try to validate the signature once more. If it still does not check out, it will raise an error.

### Query webhook events

To search for webhooks events, run:

```elixir
events = StarkBank.Event.query!(
  after: "2020-03-20",
  is_delivered: false,
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

### Get webhook event

You can get a specific webhook event by its id.

```elixir
event = StarkBank.Event.get!("4568139664719872")
  |> IO.inspect
```

### Delete webhook event

You can also delete a specific webhook event by its id.

```elixir
event = StarkBank.Event.delete!("4568139664719872")
  |> IO.inspect
```

### Set webhook events as delivered

This can be used in case you've lost events.
With this function, you can manually set events retrieved from the API as
"delivered" to help future event queries with `is_delivered: false`.

```elixir
event = StarkBank.Event.update!("5764442407043072", is_delivered: true)
  |> IO.inspect
```

## Handling errors

The SDK may raise or return errors as the StarkBank.Error struct, which contains the "code" and "message" attributes.

If you use bang functions, the list of errors will be converted into a string and raised.
If you use normal functions, the list of error structs will be returned so you can better analyse them.
