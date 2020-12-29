# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to the following versioning pattern:

Given a version number MAJOR.MINOR.PATCH, increment:

- MAJOR version when the **API** version is incremented. This may include backwards incompatible changes;
- MINOR version when **breaking changes** are introduced OR **new functionalities** are added in a backwards compatible manner;
- PATCH version when backwards compatible bug **fixes** are implemented.


## [Unreleased]
### Fixed
- Missing brcode-payment in payment request processing
### Added
- Organization user

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
