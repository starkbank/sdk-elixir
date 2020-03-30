# Stark Bank Elixir SDK

Welcome to the Stark Bank Elixir SDK! This tool is made for Elixir 
developers who want to easily integrate with our API.
This SDK version is compatible with the Stark Bank API v2.

If you have no idea what Stark Bank is, check out our [website](https://www.StarkBank.com/) 
and discover a world where receiving or making payments 
is as easy as sending a text message to your client!

## Supported Elixir Versions

This library supports Elixir versions 1.9+.

## Stark Bank API documentation

If you want to take a look at our API, follow [this link](https://docs.api.StarkBank.com/?version=latest).

## Installation

To install the package with mix, add this to your deps and run `mix deps.get`:

```elixir
def deps do
  [
    {:starkbank, "~> 2.0.0"}
  ]
end
```

## Creating a Project

To connect to the Stark Bank API, you need user credentials. We currently have 2
kinds of users: Members and Projects. Given the purpose of this SDK, it only
supports Projects, which is a type of user made specially for direct API
integrations. To start using the SDK, create your first Sandbox Project in our 
[website](https://sandbox.web.StarkBank.com) in the Project session.

Once you've created your project, you can load it in the SDK by doing:

```elixir
user = StarkBank.User.project(
    :sandbox,
    "5671398416568321",
    """
        -----BEGIN EC PRIVATE KEY-----
        MHQCAQEEIOJ3xkQ9NRdMPLLSrX3OlaoexG8JZgQyTMdX1eISCXaCoBcGBSuBBAAK
        oUQDQgAEUneBQJsBhZl8/nPQd4YUe/UqEAtyJRH01YyWrg+nsNcSRlc1GzC3DB+X
        CPZXBUbsMQAbLoWXIN1pqIX2b/NE9Q==
        -----END EC PRIVATE KEY-----
    """
)
```

Once you are done testing and want to move to Production, create a new Project
in your Production account ([click here](https://web.StarkBank.com)). Also,
when you are loading your Project, change the environment from `"sandbox"` to
`"production"` in the constructor shown above. 

NOTE: Never hard-code your private key. Get it from an environment variable, for example. 

## Setting up the user

All methods request that you pass the user as the first argument. For example:

```elixir
balance = StarkBank.Balance.get!(project)
```

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
(for example: `StarkBank.Boleto.Data |> h`)

**Note**: Almost all SDK functions also provide a bang (!) version. To simplify the examples, they will be used the most throughout this README.

### Get balance

To know how much money you have in your workspace, run:

```elixir
balance = StarkBank.Balance.get!(user)
IO.puts(balance.amount / 100)
```

### Create boletos

You can create boletos to charge customers or to receive money from accounts
you have in other banks.

```elixir
boletos = StarkBank.Boleto.create!(
  user,
  [
    %StarkBank.Boleto.Data{
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
)
```

### Get boleto

After its creation, information on a boleto may be retrieved by passing its id. 
Its status indicates whether it's been paid.

```elixir
boleto = StarkBank.Boleto.get!(user, "6750458353811456")
```

### Get boleto PDF

After its creation, a boleto PDF may be retrieved by passing its id. 

```elixir
pdf = StarkBank.Boleto.pdf!(user, "6750458353811456")

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
boleto = StarkBank.Boleto.delete!(user, "6750458353811456")
```

### Query boletos

You can get a stream of created boletos given some filters.

```elixir
boletos = StarkBank.Boleto.query!(
  user,
  after_: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  limit: 10
) |> Enum.take(10)
```

### Query boleto logs

Logs are pretty important to understand the life cycle of a boleto.

```elixir
for log <- StarkBank.Boleto.Log.query!(user, boleto_ids: ["6750458353811456"]) do log |> IO.inspect end
```

### Get a boleto log

You can get a single log by its id.

```elixir
log = StarkBank.Boleto.Log.get!(user, "6288576484474880")
```

### Create transfers

You can also create transfers in the SDK (TED/DOC).

```elixir
transfers = StarkBank.Transfer.create!(
  user,
  [
    %StarkBank.Transfer.Data{
        amount: 100,
        bank_code: "01",
        branch_code: "0001",
        account_number: "10000-0",
        tax_id: "012.345.678-90",
        name: "Tony Stark",
        tags: ["iron", "suit"]
    },
    %StarkBank.Transfer.Data{
        amount: 200,
        bank_code: "341",
        branch_code: "1234",
        account_number: "123456-7",
        tax_id: "012.345.678-90",
        name: "Jon Snow",
    }
])
```

### Query transfers

You can query multiple transfers according to filters.

```elixir
for transfer <- StarkBank.Transfer.query!(
  user,
  after_: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  limit: 10
) do transfer |> IO.inspect end
```

### Get transfer

To get a single transfer by its id, run:

```elixir
transfer = StarkBank.Transfer.get!(user, "4882890932355072")
```

### Get transfer PDF

After its creation, a transfer PDF may also be retrieved by passing its id. 

```elixir
pdf = StarkBank.Transfer.pdf!(user, "4882890932355072")

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
logs = StarkBank.Transfer.Log.query!(user, limit: 50) |> Enum.take(50)
```

### Get a transfer log

You can also get a specific log by its id.

```elixir
transfer = StarkBank.Transfer.Log.get!(user, "6751741127163904")
```

### Pay a boleto

Paying a boleto is also simple.

```elixir
payments = StarkBank.Payment.Boleto.create!(
  user,
  [
    %StarkBank.Payment.Boleto.Data{
        line: "34191.09008 61207.727308 71444.640008 5 81310001234321",
        tax_id: "012.345.678-90",
        scheduled: Date.utc_today |> Date.add(10),
        description: "take my money",
        tags: ["take", "my", "money"],
    },
    %StarkBank.Payment.Boleto.Data{
        bar_code: "34197819200000000011090063609567307144464000",
        tax_id: "012.345.678-90",
        scheduled: Date.utc_today |> Date.add(40),
        description: "take my money one more time",
        tags: ["again"],
    },
  ]
)
```

### Get boleto payment

To get a single boleto payment by its id, run:

```elixir
payment = StarkBank.Payment.Boleto.get!(user, "5629412477239296")
```

### Get boleto payment PDF

After its creation, a boleto payment PDF may be retrieved by passing its id. 

```elixir
pdf = StarkBank.Payment.Boleto.pdf!(user, "5629412477239296")

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
payment = StarkBank.Payment.Boleto.delete!(user, "5629412477239296")
```

### Query boleto payments

You can search for boleto payments using filters. 

```elixir
payments = StarkBank.Payment.Boleto.query!(
  user,
  tags: ["company_1", "company_2"]
) |> Enum.take(10)
```

### Query boleto payment logs

Searches are also possible with boleto payment logs:

```elixir
for log <- StarkBank.Payment.Boleto.Log.query!(
  user,
  payment_ids: ["5629412477239296", "5199478290120704"],
) do log |> IO.inspect end
```

### Get boleto payment log

You can also get a boleto payment log by specifying its id.

```elixir

log = StarkBank.Payment.Boleto.Log.get!(user, "5391671273455616")
```

### Create utility payment

Its also simple to pay utility bills (such electricity and water bills) in the SDK.

```elixir
payments = StarkBank.Payment.Utility.create!(
  user,
  [
    %StarkBank.Payment.Utility.Data{
        bar_code: "83660000004463001380074119002551100010601813",
        scheduled: Date.utc_today |> Date.add(2),
        description: "paying some bills",
        tags: ["take", "my", "money"],
    },
    %StarkBank.Payment.Utility.Data{
        line: "83660000005 0 10430138007 7 41190025511 7 00010601813 8",
        scheduled: Date.utc_today |> Date.add(3),
        description: "never ending bills",
        tags: ["again"],
    },
  ]
)
```

### Query utility payments

To search for utility payments using filters, run:

```elixir
payments = StarkBank.Payment.Utility.query!(
  user,
  tags: ["electricity", "gas"]
) |> Enum.take(10)
```

### Get utility payment

You can get a specific bill by its id:

```elixir
payment = StarkBank.Payment.Utility.get!(user, "6619425641857024")
```

### Get utility payment PDF

After its creation, a utility payment PDF may also be retrieved by passing its id. 

```elixir
pdf = StarkBank.Payment.Utility.pdf!(user, "6619425641857024")

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
payment = StarkBank.Payment.Utility.delete!(user, "6619425641857024")
```

### Query utility bill payment logs

You can search for payments by specifying filters. Use this to understand the
bills life cycles.

```elixir
for log <- StarkBank.Payment.Utility.Log.query!(
  user,
  payment_ids: ["6619425641857024", "5738969660653568"]
) do log |> IO.inspect end
```

### Get utility bill payment log

If you want to get a specific payment log by its id, just run:

```elixir
log = StarkBank.Payment.Utility.Log.get!(user, "6197807794880512")
```

### Create transactions

To send money between Stark Bank accounts, you can create transactions:

```elixir
transactions = StarkBank.Transaction.create!(
  user,
  [
    %StarkBank.Transaction.Data{
        amount: 100,  # (R$ 1.00)
        receiver_id: "5768064935133184",
        description: "Transaction to dear provider",
        external_id: "12345",  # so we can block anything you send twice by mistake
        tags: ["provider"]
    },
    %StarkBank.Transaction.Data{
        amount: 234,  # (R$ 2.34)
        receiver_id: "5768064935133184",
        description: "Transaction to the other provider",
        external_id: "12346",  # so we can block anything you send twice by mistake
        tags: ["provider"]
    }
  ]
)
```

### Query transactions

To understand your balance changes (bank statement), you can query
transactions. Note that our system creates transactions for you when
you receive boleto payments, pay a bill or make transfers, for example.

```elixir
transactions = StarkBank.Transaction.query!(
  user,
  after_: "2020-03-20",
  before: "2020-03-30"
) |> Enum.take(10)
```

### Get transaction

You can get a specific transaction by its id:

```elixir
transaction = StarkBank.Transaction.get!(user, "6677396233125888")
```

### Create webhook subscription

To create a webhook subscription and be notified whenever an event occurs, run:

```elixir
webhook = StarkBank.Webhook.create!(
  user,
  "https://webhook.site/dd784f26-1d6a-4ca6-81cb-fda0267761ec",
  ["transfer", "boleto", "boleto-payment", "utility-payment"]
)
```

### Query webhooks

To search for registered webhooks, run:

```elixir
for webhook <- StarkBank.Webhook.query!(user) do webhook |> IO.inspect end
```

### Get webhook

You can get a specific webhook by its id.

```elixir
webhook = StarkBank.Webhook.get!(user, "6178044066660352")
```

### Delete webhook

You can also delete a specific webhook by its id.

```elixir
webhook = StarkBank.Webhook.delete!(user, "6178044066660352")
```

### Process webhook events

Its easy to process events that arrived in your webhook. Remember to pass the
signature header so the SDK can make sure its really StarkBank that sent you
the event.

```elixir
response = listen()  # this is the function you made to get the events posted to your webhook

{event, cache_pid} = StarkBank.Webhook.Event.parse!(
  user,
  response.content,
  response.headers["Digital-Signature"]
)
```

To avoid making unnecessary requests to the API (/GET public-key), you can pass the `cache_pid` (returned on all requests)
on your next parse. The process referred by the PID `cache_pid` will store the latest Stark Bank public key
and refresh it whenever an inconsistency is found between the content, signature and current public key.

**Note**: If you don't send the cache_pid to the parser, a new cache process will be generated.

```elixir
{event, _cache_pid} = StarkBank.Webhook.Event.parse!(
  user,
  response.content,
  response.headers["Digital-Signature"],
  cache_pid
)
```

If the data does not check out with the Stark Bank public-key, the function will automatically request the
key from the API and try to validate the signature once more. If it still does not check out, it will raise an error.

### Query webhook events

To search for webhooks events, run:

```elixir
events = StarkBank.Webhook.Event.query!(
  user,
  after_: "2020-03-20",
  is_delivered: false,
  limit: 10
) |> Enum.take(10)
```

### Get webhook event

You can get a specific webhook event by its id.

```elixir
event = StarkBank.Webhook.Event.get!(user, "4568139664719872")
```

### Delete webhook event

You can also delete a specific webhook event by its id.

```elixir
event = StarkBank.Webhook.Event.delete!(user, "4568139664719872")
```

### Set webhook events as delivered

This can be used in case you've lost events.
With this function, you can manually set events retrieved from the API as
"delivered" to help future event queries with `is_delivered=False`.

```elixir
events = StarkBank.Webhook.Event.set_delivered!(user, id="4652205932019712")
```

## Handling errors

The SDK may raise or return errors as the StarkBank.Error struct, which contains the "code" and "message" attributes.

If you use bang functions, the list of errors will be converted into a string and raised.
If you use normal functions, the list of error structs will returned so you can better analyse them.


## Key pair generation

The SDK provides a helper to allow you to easily create ECDSA secp256k1 keys to use
within our API. If you ever need a new pair of keys, just run:

```elixir
{private_key, public_key} = StarkBank.Key.create()

# or, to also save .pem files in a specific path
{private_key, public_key} = StarkBank.Key.create("file/keys/")
```

**Note**: When you are creating a new Project, it is recommended that you create the
keys inside the infrastructure that will use it, in order to avoid risky internet
transmissions of your **private-key**. Then you can export the **public-key** alone to the
computer where it will be used in the new Project creation.


[API docs]: (https://docs.api.StarkBank.com/?version=v2)