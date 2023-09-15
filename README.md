# Stark Bank Elixir SDK Beta

Welcome to the Stark Bank Elixir SDK! This tool is made for Elixir
developers who want to easily integrate with our API.
This SDK version is compatible with the Stark Bank API v2.

If you have no idea what Stark Bank is, check out our [website](https://www.StarkBank.com/)
and discover a world where receiving or making payments
is as easy as sending a text message to your client!

# Introduction

# Index

- [Introduction](#introduction)
    - [Supported Elixir versions](#supported-elixir-versions)
    - [API documentation](#stark-bank-api-documentation)
    - [Versioning](#versioning)
- [Setup](#setup)
    - [Install our SDK](#1-install-our-sdk)
    - [Create your Private and Public Keys](#2-create-your-private-and-public-keys)
    - [Register your user credentials](#3-register-your-user-credentials)
    - [Setting up the user](#4-setting-up-the-user)
    - [Setting up the error language](#5-setting-up-the-error-language)
    - [Resource listing and manual pagination](#6-resource-listing-and-manual-pagination)
- [Testing in Sandbox](#testing-in-sandbox) 
- [Usage](#usage)
    - [Transactions](#create-transactions): Account statement entries
    - [Balance](#get-balance): Account balance
    - [Transfers](#create-transfers): Wire transfers (TED and manual Pix)
    - [DictKeys](#get-dict-key): Pix Key queries to use with Transfers
    - [Institutions](#query-bacen-institutions): Instutitions recognized by the Central Bank
    - [Invoices](#create-invoices): Reconciled receivables (dynamic PIX QR Codes)
    - [Deposits](#query-deposits): Other cash-ins (static PIX QR Codes, manual PIX, etc)
    - [Boletos](#create-boletos): Boleto receivables
    - [BoletoHolmes](#investigate-a-boleto): Boleto receivables investigator
    - [BrcodePayments](#pay-a-br-code): Pay Pix QR Codes
    - [BoletoPayments](#pay-a-boleto): Pay Boletos
    - [UtilityPayments](#create-utility-payments): Pay Utility bills (water, light, etc.)
    - [TaxPayments](#create-tax-payments): Pay taxes
    - [PaymentPreviews](#preview-payment-information-before-executing-the-payment): Preview all sorts of payments
    - [Webhooks](#create-a-webhook-subscription): Configure your webhook endpoints and subscriptions
    - [WebhookEvents](#process-webhook-events): Manage webhook events
    - [WebhookEventAttempts](#query-failed-webhook-event-delivery-attempts-information): Query failed webhook event deliveries
    - [Workspaces](#create-a-new-workspace): Manage your accounts
- [Handling errors](#handling-errors)
- [Help and Feedback](#help-and-feedback)

# Supported Elixir Versions

This library supports Elixir versions 1.9+.

# Stark Bank API documentation

Feel free to take a look at our [API docs](https://www.starkbank.com/docs/api).

# Versioning

This project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.

# Setup

## 1. Install our SDK

To install the package with mix, add this to your deps and run `mix deps.get`:

```elixir
def deps do
  [
    {:starkbank, "~> 2.6.2"}
  ]
end
```

## 2. Create your Private and Public Keys

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

## 3. Register your user credentials

You can interact directly with our API using two types of users: Projects and Organizations.

- **Projects** are workspace-specific users, that is, they are bound to the workspaces they are created in.
One workspace can have multiple Projects.
- **Organizations** are general users that control your entire organization.
They can control all your Workspaces and even create new ones. The Organization is bound to your company's tax ID only.
Since this user is unique in your entire organization, only one credential can be linked to it.

3.1. To create a Project in Sandbox:

3.1.1. Log into [Starkbank Sandbox](https://web.sandbox.starkbank.com)

3.1.2. Go to Menu > Integrations

3.1.3. Click on the "New Project" button

3.1.4. Create a Project: Give it a name and upload the public key you created in section 2

3.1.5. After creating the Project, get its Project ID

3.1.6. Use the Project ID and private key to create the object below:

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

project = StarkBank.project(
    id: "5671398416568321",
    environment: :sandbox,
    private_key: private_key_content
)
```

3.2. To create Organization credentials in Sandbox:

3.2.1. Log into [Starkbank Sandbox](https://web.sandbox.starkbank.com)

3.2.2. Go to Menu > Integrations

3.2.3. Click on the "Organization public key" button

3.2.4. Upload the public key you created in section 2 (only a legal representative of the organization can upload the public key)

3.2.5. Click on your profile picture and then on the "Organization" menu to get the Organization ID

3.2.6. Use the Organization ID and private key to create the object below:

```elixir
# Get your private key from an environment variable or an encrypted database.
# This is only an example of a private key content. You should use your own key.
private_key_content = """
-----BEGIN EC PARAMETERS-----
BgUrgQQACg==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIMCwW74H6egQkTiz87WDvLNm7fK/cA+ctA2vg/bbHx3woAcGBSuBBAAK
oUQDQgAE0iaeEHEgr3oTbCfh8U2L+r7zoaeOX964xaAnND5jATGpD/tHec6Oe9U1
IF16ZoTVt1FzZ8WkYQ3XomRD4HS13A==
-----END EC PRIVATE KEY-----
"""

organization = StarkBank.Organization(
    environment: "sandbox",
    id: "5656565656565656",
    private_key: private_key_content,
    workspace_id: nil,  # You only need to set the workspace_id when you are operating a specific workspace_id
)

# To dynamically use your organization credentials in a specific workspace_id,
# you can use the Organization.replace() method:
StarkBank.Balance.get!(user: organization |> StarkBank.Organization.replace("4848484848484848"))
  |> IO.inspect()
```

NOTE 1: Never hard-code your private key. Get it from an environment variable or an encrypted database.

NOTE 2: We support `'sandbox'` and `'production'` as environments.

NOTE 3: The credentials you registered in `sandbox` do not exist in `production` and vice versa.

## 4. Setting up the user

There are three kinds of users that can access our API: **Organization**, **Project** and **Member**.

- `Project` and `Organization` are designed for integrations and are the ones meant for our SDKs.
- `Member` is the one you use when you log into our webpage with your e-mail.

There are two ways to inform the user to the SDK:
 
4.1 Passing the user as argument in all functions using the `user` keyword:

```elixir
balance = StarkBank.Balance.get!(user: project)  # or organization
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

or

```elixir
import Config

config :starkbank,
  organization: [
    environment: :sandbox,
    id: "9999999999999999",
    private_key: private_key_content,
    workspace_id: "8888888888888888" # or nil
  ]
```

Just select the way of passing the user that is more convenient to you.
On all following examples we will assume a default user has been set in the configs.


## 5. Setting up the error language

The error language can also be set in the `config/config.exs` file:

```elixir
import Config

config :starkbank,
  language: "en-US"
```

Language options are "en-US" for english and "pt-BR" for brazilian portuguese. English is default

## 6. Resource listing and manual pagination

Almost all SDK resources provide a `query` and a `page` function.

- The `query` function provides a straight forward way to efficiently iterate through all results that match the filters you inform,
seamlessly retrieving the next batch of elements from the API only when you reach the end of the current batch.
If you are not worried about data volume or processing time, this is the way to go.

```elixir
transactions = StarkBank.Transaction.query!(
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1)
) |> Enum.take(10) |> IO.inspect
```

- The `page` function gives you full control over the API pagination. With each function call, you receive up to
100 results and the cursor to retrieve the next batch of elements. This allows you to stop your queries and
pick up from where you left off whenever it is convenient. When there are no more elements to be retrieved, the returned cursor will be `nil`.

```elixir
defmodule CursorRecursion do
  def get!(iterations \\ 1, cursor \\ nil)  

  def get!(iterations, cursor) when iterations > 0 do
    {new_cursor, new_entities} = StarkBank.Transaction.page!(cursor: cursor)
    new_entities ++ get!(
      iterations - 1,
      new_cursor
    )
  end

  def get!(iterations, _cursor) do
    []
  end
end

transactions = CursorRecursion.get!(3) |> IO.inspect
```

To simplify the following SDK examples, we will only use the `query` function, but feel free to use `page` instead.

# Testing in Sandbox

Your initial balance is zero. For many operations in Stark Bank, you'll need funds
in your account, which can be added to your balance by creating an Invoice or a Boleto. 

In the Sandbox environment, most of the created Invoices and Boletos will be automatically paid,
so there's nothing else you need to do to add funds to your account. Just create
a few Invoices and wait around a bit.

In Production, you (or one of your clients) will need to actually pay this Invoice or Boleto
for the value to be credited to your account.


# Usage

Here are a few examples on how to use the SDK. If you have any doubts, use the built-in
`h()` function to get more info on the desired functionality
(for example: `StarkBank.Boleto |> h`)

**Note**: Almost all SDK functions also provide a bang (!) version. To simplify the examples, they will be used the most throughout this README.


## Create transactions

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

## Query transactions

To understand your balance changes (bank statement), you can query
transactions. Note that our system creates transactions for you when
you receive boleto payments, pay a bill or make transfers, for example.

```elixir
transactions = StarkBank.Transaction.query!(
  after: Date.utc_today |> Date.add(-30),
  before: Date.utc_today |> Date.add(-1)
) |> Enum.take(10) |> IO.inspect
```

## Get a transaction

You can get a specific transaction by its id:

```elixir
transaction = StarkBank.Transaction.get!("6677396233125888")
  |> IO.inspect
```

## Get balance

To know how much money you have in your workspace, run:

```elixir
balance = StarkBank.Balance.get!()
IO.puts(balance.amount / 100)
```

## Create transfers

You can also create transfers in the SDK (TED/Pix).

```elixir
transfers = StarkBank.Transfer.create!(
  [
    %StarkBank.Transfer{
        amount: 100,
        bank_code: "20018183",  # Pix
        branch_code: "0001",
        account_number: "10000-0",
        tax_id: "012.345.678-90",
        name: "Tony Stark",
        tags: ["iron", "suit"]
    },
    %StarkBank.Transfer{
        amount: 200,
        bank_code: "341",  # TED
        branch_code: "1234",
        account_number: "123456-7",
        account_type: "salary",
        external_id: "my-internal-id-12345",
        tax_id: "012.345.678-90",
        name: "Jon Snow",
        scheduled: Date.utc_today |> Date.add(30)
    }
]) |> IO.inspect
```

**Note**: Instead of using Transfer structs, you can also pass each transfer element in map format

## Query transfers

You can query multiple transfers according to filters.

```elixir
for transfer <- StarkBank.Transfer.query!(
  after: Date.utc_today |> Date.add(-30),
  limit: 10
) do
  transfer |> IO.inspect
end
```

## Get a transfer

To get a single transfer by its id, run:

```elixir
transfer = StarkBank.Transfer.get!("4882890932355072")
  |> IO.inspect
```

## Cancel a transfer

To cancel a single scheduled transfer by its id, run:

```elixir
transfer = StarkBank.Transfer.delete!("4882890932355072")
  |> IO.inspect
```

## Get a transfer PDF

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

## Query transfer logs

You can query transfer logs to better understand transfer life cycles.

```elixir
logs = StarkBank.Transfer.Log.query!(limit: 50)
  |> Enum.take(50)
  |> IO.inspect
```

## Get a transfer log

You can also get a specific log by its id.

```elixir
log = StarkBank.Transfer.Log.get!("6610264099127296")
  |> IO.inspect
```

## Get DICT key

You can get DICT (Pix) key's parameters by its id.

```elixir
dict_key = StarkBank.DictKey.get!("tony@starkbank.com")
  |> IO.inspect
```

## Query your DICT keys

To take a look at the DICT keys linked to your workspace, just run the following:

```elixir
dict_key = StarkBank.DictKey.query!(
  limit: 1,
  status: "registered",
  type: "evp"
) |> Enum.take(1) |> IO.inspect
```

## Query Bacen institutions

You can query institutions registered by the Brazilian Central Bank for Pix and TED transactions.

```elixir
institutions = StarkBank.Institution.query(search: "stark") |> IO.inspect
```

## Create invoices

You can create dynamic QR Code invoices to charge customers or to receive money from accounts you have in other banks. 

Since the banking system only understands value modifiers (discounts, fines and interest) when dealing with **dates** (instead of **datetimes**), these values will only show up in the end user banking interface if you use **dates** in the "due" and "discounts" fields. 

If you use **datetimes** instead, our system will apply the value modifiers in the same manner, but the end user will only see the final value to be paid on his interface.

Also, other banks will most likely only allow payment scheduling on invoices defined with **dates** instead of **datetimes**.

```elixir
invoice = StarkBank.Invoice.create!(
  [
    %StarkBank.Invoice{
      amount: 400000,
      due: DateTime.utc_now |> DateTime.add(24 * 3600 * 3),
      tax_id: "012.345.678-90",
      name: "Iron Bank S.A.",
      expiration: 123456789,
      fine: 2.5,
      interest: 1.3,
      discounts: [
        %{
          percentage: 10,
          due: DateTime.utc_now |> DateTime.add(24 * 3600 * 2)
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

## Get an invoice

After its creation, information on an invoice may be retrieved by its id. 
Its status indicates whether it's been paid.

```elixir
invoice = StarkBank.Invoice.get!("6750458353811456")
  |> IO.inspect
```

## Get an invoice PDF

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

## Get an invoice QR Code 

After its creation, an invoice QR Code png file may be retrieved by its id. 

```elixir
qrcode = StarkBank.Invoice.qrcode!("5443064852119552")

file = File.open!("invoice.png", [:write])
IO.binwrite(file, qrcode)
File.close(file)
```

## Cancel an invoice

You can also cancel an invoice by its id.
Note that this is not possible if it has been paid already.

```elixir
invoice = StarkBank.Invoice.update!("6750458353811456", status: "canceled")
  |> IO.inspect
```

## Update an invoice

You can update an invoice's amount, due date and expiration by its id.
Note that this is not possible if it has been paid already.

```elixir
invoice = StarkBank.Invoice.update!(
  "6750458353811456", 
  amount: 123456, 
  due: DateTime.utc_now |> DateTime.add(10),
  expiration: 123456789
)
  |> IO.inspect
```

## Query invoices

You can get a list of created invoices given some filters.

```elixir
invoices = StarkBank.Invoice.query!(
  after: Date.utc_today |> Date.add(-2),
  before: Date.utc_today |> Date.add(-1),
  status: "overdue",
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

## Query invoice logs

Logs are pretty important to understand the life cycle of an invoice.

```elixir
for log <- StarkBank.Invoice.Log.query!(invoice_ids: ["6750458353811456"]) do
  log |> IO.inspect
end
```

## Get an invoice log

You can get a single log by its id.

```elixir
log = StarkBank.Invoice.Log.get!("6288576484474880")
  |> IO.inspect
```

## Get a reversed invoice log PDF

Whenever an Invoice is successfully reversed, a reversed log will be created.
To retrieve a specific reversal receipt, you can request the corresponding log PDF:

```elixir
pdf = StarkBank.Invoice.Log.pdf!("6750458353811456")

file = File.open!("invoice-log.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

## Get an invoice payment information

Once an invoice has been paid, you can get the payment information using the Invoice.Payment sub-resource:

```elixir
payment_information = StarkBank.Invoice.payment!("5155165527080960")
  |> IO.inspect
```

## Query deposits

You can get a list of created deposits given some filters.

```elixir
    for deposit <- StarkBank.Deposit.query!(
      after: "2020-10-01",
      before: "2020-10-10",
      limit: 1
    ) do
      deposit |> IO.inspect
    end
```

## Get a deposit

After its creation, information on a deposit may be retrieved by its id. 

```elixir
deposit = StarkBank.Deposit.get!("5738709764800512")
  |> IO.inspect
```

## Query deposit logs

Logs are pretty important to understand the life cycle of a deposit.

```elixir
logs = StarkBank.Deposit.Log.query!(
  limit: 10,
  after: "2020-11-01",
  before: "2020-11-02"
  )
|> Enum.take(10)
|> IO.inspect
```

## Get a deposit log

You can get a single log by its id.

```elixir
log = StarkBank.Deposit.Log.get!("6610264099127296")
|> IO.inspect
```

## Create boletos

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
        due: Date.utc_today |> Date.add(2),
        fine: 5,  # 5%
        interest: 2.5,  # 2.5% per month
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using Boleto structs, you can also pass each boleto element in map format

## Get a boleto

After its creation, information on a boleto may be retrieved by passing its id.
Its status indicates whether it's been paid.

```elixir
boleto = StarkBank.Boleto.get!("6750458353811456")
  |> IO.inspect
```

## Get a boleto PDF

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

## Delete a boleto

You can also cancel a boleto by its id.
Note that this is not possible if it has been processed already.

```elixir
boleto = StarkBank.Boleto.delete!("5202697619767296")
  |> IO.inspect
```

## Query boletos

You can get a stream of created boletos given some filters.

```elixir
boletos = StarkBank.Boleto.query!(
  after: "2020-09-01",
  before: "2020-09-02",
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

## Query boleto logs

Logs are pretty important to understand the life cycle of a boleto.

```elixir
for log <- StarkBank.Boleto.Log.query!(boleto_ids: ["6750458353811456"]) do
  log |> IO.inspect
end
```

## Get a boleto log

You can get a single log by its id.

```elixir
log = StarkBank.Boleto.Log.get!("6288576484474880")
  |> IO.inspect
```

## Investigate a boleto

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

## Get a boleto holmes

To get a single Holmes by its id, run:

```elixir
sherlock = StarkBank.BoletoHolmes.get!("5629412477239296")
  |> IO.inspect
```

## Query boleto holmes

You can search for boleto Holmes using filters.

```elixir
for sherlock <- StarkBank.BoletoHolmes.query!(
  tags: ["#123", "test"],
) do
  sherlock |> IO.inspect
end
```

## Query boleto holmes logs

Searches are also possible with boleto holmes logs:

```elixir
for log <- StarkBank.BoletoHolmes.Log.query!(
  holmes_ids: ["5629412477239296", "5199478290120704"],
) do
  log |> IO.inspect
end
```

## Get a boleto holmes log

You can also get a boleto holmes log by specifying its id.

```elixir
log = StarkBank.BoletoHolmes.Log.get!("5391671273455616")
  |> IO.inspect
```

## Pay a BR Code

Paying a BR Code is also simple. After extracting the BR Code encoded in the Pix QR Code, you can do the following:

```elixir
payments = StarkBank.BrcodePayment.create!(
  [
    %StarkBank.BrcodePayment{
        brcode: "00020101021226860014br.gov.bcb.pix2564invoice-h.sandbox.starkbank.com/2b59521ba5a74a31b00efd4c6d2601a15204000053039865802BR5915Stark Bank S.A.6009Sao Paulo623605322b59521ba5a74a31b00efd4c6d2601a163046300",
        tax_id: "012.345.678-90",
        description: "paying the bill",
        tags: ["invoice#123", "bills"],
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using BrcodePayment objects, you can also pass each payment element in dictionary format

## Get a BR Code payment

To get a single BR Code payment by its id, run:

```elixir
payment = StarkBank.BrcodePayment.get!("5629412477239296")
  |> IO.inspect
```

## Get a BR Code payment PDF

After its creation, a BR Code payment PDF may be retrieved by its id. 

```elixir
pdf = StarkBank.BrcodePayment.pdf!("5629412477239296")

file = File.open!("brcode-payment.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

## Cancel a BR Code payment

You can cancel a BR Code payment by changing its status to "canceled".
Note that this is not possible if it has been processed already.

```elixir
payment = StarkBank.BrcodePayment.update!(
  "5629412477239296",
  status: "canceled"
)
  |> IO.inspect
```

## Query BR Code payments

You can search for BR Code payments using filters. 

```elixir
payments = StarkBank.BrcodePayment.query!(
  after: "2020-11-01",
  before: "2020-11-02",
  limit: 2
) |> Enum.take(2) |> IO.inspect
```

## Query BR Code payment logs

Searches are also possible with BR Code payment logs:

```elixir
for log <- StarkBank.BrcodePayment.Log.query!(
  payment_ids: ["6200426164649984"]
) do
  log |> IO.inspect
end
```

## Get a BR Code payment log

You can also get a BR Code payment log by specifying its id.

```elixir
log = StarkBank.BrcodePayment.Log.get!("5735810494103552")

log |> IO.inspect
```

## Pay a boleto

Paying a boleto is also simple.

```elixir
payments = StarkBank.BoletoPayment.create!(
  [
    %StarkBank.BoletoPayment{
        line: "34191.09008 64694.017308 71444.640008 1 96610000014500",
        tax_id: "012.345.678-90",
        scheduled: "2020-11-01",
        description: "take my money",
        tags: ["take", "my", "money"],
    },
    %StarkBank.BoletoPayment{
        bar_code: "34191972300000289001090064694197307144464000",
        tax_id: "012.345.678-90",
        scheduled: "2020-11-05",
        description: "take my money one more time",
        tags: ["again"],
    },
  ]
) |> IO.inspect
```

**Note**: Instead of using BoletoPayment structs, you can also pass each payment element in map format

## Get a boleto payment

To get a single boleto payment by its id, run:

```elixir
payment = StarkBank.BoletoPayment.get!("5629412477239296")
  |> IO.inspect
```

## Get a boleto payment PDF

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

## Delete a boleto payment

You can also cancel a boleto payment by its id.
Note that this is not possible if it has been processed already.

```elixir
payment = StarkBank.BoletoPayment.delete!("5629412477239296")
  |> IO.inspect
```

## Query boleto payments

You can search for boleto payments using filters.

```elixir
payments = StarkBank.BoletoPayment.query!(
  tags: ["company_1", "company_2"]
) |> Enum.take(10) |> IO.inspect
```

## Query boleto payment logs

Searches are also possible with boleto payment logs:

```elixir
for log <- StarkBank.BoletoPayment.Log.query!(
  payment_ids: ["5629412477239296", "5199478290120704"],
) do
  log |> IO.inspect
end
```

## Get a boleto payment log

You can also get a boleto payment log by specifying its id.

```elixir
log = StarkBank.BoletoPayment.Log.get!("5391671273455616")
  |> IO.inspect
```

## Create utility payments

It's also simple to pay utility bills (such as electricity and water bills) in the SDK.

```elixir
payments = StarkBank.UtilityPayment.create!(
  [
    %StarkBank.UtilityPayment{
        bar_code: "83600000001522801380037107172881100021296561",
        scheduled: "2020-11-05",
        description: "paying some bills",
        tags: ["take", "my", "money"],
    },
    %StarkBank.UtilityPayment{
        line: "83680000001 7 08430138003 0 71070987611 8 00041351685 7",
        scheduled: "2020-11-09",
        description: "never ending bills",
        tags: ["again"],
    },
  ]
) |> IO.inspect
```

**Note**: Instead of using UtilityPayment structs, you can also pass each payment element in map format

## Query utility payments

To search for utility payments using filters, run:

```elixir
payments = StarkBank.UtilityPayment.query!(
  tags: ["electricity", "gas"]
) |> Enum.take(10) |> IO.inspect
```

## Get a utility payment

You can get a specific bill by its id:

```elixir
payment = StarkBank.UtilityPayment.get!("6619425641857024")
  |> IO.inspect
```

## Get a utility payment PDF

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

## Delete a utility payment

You can also cancel a utility payment by its id.
Note that this is not possible if it has been processed already.

```elixir
payment = StarkBank.UtilityPayment.delete!("6619425641857024")
  |> IO.inspect
```

## Query utility payment logs

You can search for payments by specifying filters. Use this to understand the
bills life cycles.

```elixir
for log <- StarkBank.UtilityPayment.Log.query!(
  payment_ids: ["6619425641857024", "5738969660653568"]
) do
  log |> IO.inspect
end
```

## Get a utility payment log

If you want to get a specific payment log by its id, just run:

```elixir
log = StarkBank.UtilityPayment.Log.get!("6197807794880512")
  |> IO.inspect
```

## Create tax payments

It is also simple to pay taxes (such as ISS and DAS) using this SDK.

```elixir
payments = StarkBank.TaxPayment.create!(
  [
    %StarkBank.TaxPayment{
      bar_code: "85660000001549403280074119002551100010601813",
      description: "fix the road",
      tags: ["take", "my", "money"],
      scheduled: '2020-08-13'
    },
    %StarkBank.TaxPayment{
      line: "85800000003 0 28960328203 1 56072020190 5 22109674804 0",
      description: "build the hospital, hopefully",
      tags: ["expensive"],
      scheduled: '2020-08-13'
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using TaxPayment objects, you can also pass each payment element in dictionary format

## Query tax payments

To search for tax payments using filters, run:

```elixir
payments = StarkBank.TaxPayment.query(limit: 5) |> IO.inspect
```

## Get a tax payment

You can get a specific tax payment by its id:

```elixir
payment = StarkBank.TaxPayment.get!("5155165527080960") |> IO.inspect
```

## Get a tax payment PDF

After its creation, a tax payment PDF may also be retrieved by its id.

```elixir
pdf = StarkBank.TaxPayment.pdf!("5155165527080960")
file = File.open!("tmp/tax-payment.pdf", [:write])
IO.binwrite(file, pdf)
File.close(file)
```

Be careful not to accidentally enforce any encoding on the raw pdf content,
as it may yield abnormal results in the final file, such as missing images
and strange characters.

## Cancel a tax payment

You can also cancel a tax payment by its id.
Note that this is not possible if it has been processed already.

```elixir
payment = StarkBank.TaxPayment.delete!("5155165527080960") |> IO.inspect
```

## Query tax payment logs

You can search for payment logs by specifying filters. Use this to understand each payment life cycle.

```elixir
logs = StarkBank.TaxPayment.Log.query!(limit: 5) |> IO.inspect
```

## Get a tax payment log

If you want to get a specific payment log by its id, just run:

```elixir
log = StarkBank.TaxPayment.Log.get!("1902837198237992") |> IO.inspect
```

**Note**: Some taxes can't be payed with bar codes. Since they have specific parameters, each one of them has its own
resource and routes, which are all analogous to the TaxPayment resource. The ones we currently support are:
- DarfPayment, for DARFs

## Preview payment information before executing the payment

You can preview multiple types of payment to confirm any information before actually paying.
If the "scheduled" parameter is not informed, today will be assumed as the intended payment date.
Right now, the "scheduled" parameter only has effect on BrcodePreviews.
This resource is able to preview the following types of payment:
"brcode-payment", "boleto-payment", "utility-payment" and "tax-payment"

```elixir

previews = StarkBank.PaymentPreview.create!(
  [
    %StarkBank.PaymentPreview{
      id: "00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A",
      scheduled: '2020-08-13'
    },
    %StarkBank.PaymentPreview{
      id: "34191.09008 61207.727308 71444.640008 5 81310001234321"
    }
  ]
) |> IO.inspect
```

**Note**: Instead of using PaymentPreview structs, you can also pass each payment request element in map format

## Create payment requests to be approved by authorized people in a cost center 

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
        due: "2020-10-01",
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


## Query payment requests

To search for payment requests, run:

```elixir
requests = StarkBank.PaymentRequest.query!(
  center_id: "5967314465849344",
  after: "2020-10-09",
  before: "2020-10-10",
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

## Create a webhook subscription

To create a webhook subscription and be notified whenever an event occurs, run:

```elixir
webhook = StarkBank.Webhook.create!(
  url: "https://webhook.site/dd784f26-1d6a-4ca6-81cb-fda0267761ec",
  subscriptions: ["transfer", "deposit", "invoice", "brcode-payment", "utility-payment", "boleto", "boleto-payment"]
) |> IO.inspect
```

## Query webhooks

To search for registered webhooks, run:

```elixir
for webhook <- StarkBank.Webhook.query!() do
  webhook |> IO.inspect
end
```

## Get a webhook subscription

You can get a specific webhook by its id.

```elixir
webhook = StarkBank.Webhook.get!("6178044066660352")
  |> IO.inspect
```

## Delete a webhook subscription

You can also delete a specific webhook by its id.

```elixir
webhook = StarkBank.Webhook.delete!("6178044066660352")
  |> IO.inspect
```

## Process webhook events

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

## Query webhook events

To search for webhooks events, run:

```elixir
events = StarkBank.Event.query!(
  after: "2020-03-20",
  is_delivered: false,
  limit: 10
) |> Enum.take(10) |> IO.inspect
```

## Get a webhook event

You can get a specific webhook event by its id.

```elixir
event = StarkBank.Event.get!("4568139664719872")
  |> IO.inspect
```

## Delete a webhook event

You can also delete a specific webhook event by its id.

```elixir
event = StarkBank.Event.delete!("4568139664719872")
  |> IO.inspect
```

## Set webhook events as delivered

This can be used in case you've lost events.
With this function, you can manually set events retrieved from the API as
"delivered" to help future event queries with `is_delivered: false`.

```elixir
event = StarkBank.Event.update!("5764442407043072", is_delivered: true)
  |> IO.inspect
```

## Query failed webhook event delivery attempts information

You can also get information on failed webhook event delivery attempts.

```elixir
for attempt <- StarkBank.Event.Attempt.query!(after: "2020-03-20") do
  attempt |> IO.inspect attempt
end
```

## Get a failed webhook event delivery attempt information

To retrieve information on a single attempt, use the following function:

```elixir
attempt = StarkBank::Event::Attempt.get("1616161616161616")
  |> IO.inspect
```

## Create a new Workspace

The Organization user allows you to create new Workspaces (bank accounts) under your organization.
Workspaces have independent balances, statements, operations and users.
The only link between your Workspaces is the Organization that controls them.

**Note**: This route will only work if the Organization user is used with `workspace_id=nil`.

```elixir
workspace = StarkBank.Workspace.create!(
  username: "starkbank-workspace",
  name: "Stark Bank Workspace"
) |> IO.inspect
```

## List your Workspaces

This route lists Workspaces. If no parameter is passed, all the workspaces the user has access to will be listed, but
you can also find other Workspaces by searching for their usernames or IDs directly.

```elixir
workspaces = StarkBank.Workspace.query!(limit: 10)
  |> IO.inspect
```

## Get a Workspace

You can get a specific Workspace by its id.

```elixir
workspace = StarkBank.Workspace.get!("10827361982368179")
  |> IO.inspect
```

## Update a Workspace

You can update a specific Workspace by its id.

```elixir

workspace = StarkBank.Workspace.update!(
  "10827361982368179",
  username: "new-username-test",
  name: "Updated workspace test",
  allowedTaxIds: ["359.536.680-82", "20.018.183/0001-80"]
) |> IO.inspect
```

# Handling errors

The SDK may raise or return errors as the StarkBank.Error struct, which contains the "code" and "message" attributes.

If you use bang functions, the list of errors will be converted into a string and raised.
If you use normal functions, the list of error structs will be returned so you can better analyse them.

# Help and Feedback

If you have any questions about our SDK, just send us an email.
We will respond you quickly, pinky promise. We are here to help you integrate with us ASAP.
We also love feedback, so don't be shy about sharing your thoughts with us.

Email: developers@starkbank.com
