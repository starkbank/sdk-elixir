# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.


## [Unreleased]
### Changed
- starkbank-ecdsa library version to 1.0.1

## [2.6.0] - 2021-09-04
### Added
- Support for scheduled invoices, which will display discounts, fine, interest, etc. on the users banking interface when dates are used instead of datetimes
- PaymentPreview resource to preview multiple types of payments before confirmation: BrcodePreview, BoletoPreview, UtilityPreview and TaxPreview

## [2.5.0] - 2021-08-10
### Added
- "payment" account type for Pix related resources
- missing parameters to Boleto, BrcodePayment, DictKey, Event, Invoice, Transfer and Workspace resources
- Workspace.update() to allow parameter updates
- Invoice.Payment sub-resource to allow retrieval of invoice payment information
- Event.Attempt sub-resource to allow retrieval of information on failed webhook event delivery attempts
- pdf method for retrieving PDF receipts from reversed invoice logs
- page functions as a manual-pagination alternative to queries
- Institution resource to allow query of institutions recognized by the Brazilian Central Bank for Pix and TED transactions
- TaxPayment resource
- DarfPayment resource

## [2.4.1] - 2021-03-19
### Fixed
- "+" character bug in BrcodePreview

## [2.4.0] - 2021-01-21
### Added
- Transfer.account_type property to allow "checking", "salary" or "savings" account specification
- Transfer.external_id property to allow users to take control over duplication filters

## [2.3.0] - 2021-01-19
### Fixed
- Missing brcode-payment in payment request processing
### Added
- Organization user
- Workspace resource

## [2.2.0] - 2020-11-24
### Added
- Invoice resource to load your account with dynamic QR Codes
- Deposit resource to receive transfers passively
- DictKey resource to get DICT (PIX) key parameters
- PIX support in Transfer resource
- BrcodePayment support to pay static and dynamic PIX QR Codes

## [2.1.0] - 2020-10-28
### Added
- BoletoHolmes to investigate boleto status according to CIP

## [2.0.0] - 2020-10-20
### Added
- ids parameter to Transaction.query
- ids parameter to Transfer.query
- PaymentRequest resource to pass payments through manual approval flow

## [0.6.0] - 2020-08-20
### Added
- transfer.scheduled parameter to allow Transfer scheduling
- StarkBank.Transfer.delete to cancel scheduled Transfers
- Transaction query by tags
### Fixed
- Event errors on unknown subscriptions

## [0.5.1] - 2020-06-09
### Fixed
- Production bug on Mix call inside SDK

## [0.5.0] - 2020-06-05
### Added
- Travis CI integration
- Boleto PDF layout option
- Global error language config
- Transfer tax_id query parameter
### Change
- Test user credentials to environment variable instead of hard-code

## [0.4.0] - 2020-05-12
### Added
- "receiver_name" & "receiver_tax_id" properties to Boleto entities

## [0.3.1] - 2020-05-05
### Fixed
- Docstrings

## [0.3.0] - 2020-05-04
### Added
- "discounts" property to Boleto entities
- Support for list of maps in create functions
- "balance" property to Transaction entities
### Fixed
- Docstrings and specs

## [0.2.0] - 2020-04-20
### Added
- Default user in config.exs
### Changed
- Internal structure
### Fixed
- Docstrings and specs

## [0.1.0] - 2020-04-17
### Removed
- All previous implementations
### Added
- Full Stark Bank API v2 compatibility
