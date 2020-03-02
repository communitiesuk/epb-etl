# ETL Pipeline

![](https://github.com/communitiesuk/epb-etl/workflows/Test/badge.svg)

This repository is responsible for the Extract, Transform, Load (ETL) pipeline
for the Energy Performance of Buildings Register (EPBR) data migration.
[Terraform](https://www.terraform.io) is used to provision and manage
infrastructure in Amazon Web Services (AWS) cloud. Some of the AWS services used
include, but not limited to: [Lambda](https://aws.amazon.com/lambda),
[SNS](https://aws.amazon.com/sns) and [SQS](https://aws.amazon.com/sqs). The
pipeline is designed to accommodate any database (DB) system - Oracle,
PostgreSQL, etc.

## Overview

Below is a diagram that illustrates the flow and process of the ETL pipeline.

![ETL Architecture](docs/images/etl-architecture.png)

## Setup

The ETL pipeline is currently set up to work with
[Oracle DB](https://www.oracle.com/database), so for the purpose of this guide,
we will be using the Oracle DB system. Follow the OS specific guide from the
links below.

### Operating System

- [MacOS](docs/macos)

## Usage

### Test

Use the following commands to run all or a particular type of test:

```shell script
$ make test # run all acceptance and unit tests

$ make test_integration # run all integration tests

$ make test_e2e # run all end-to-end tests

$ make test_all # run all tests
```

## Documentation

### Technical Architecture

The AWS Lambda function located in the `lib` folder follows the principles of
[Clean Architecture (CA)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
and is written in the [Ruby](https://www.ruby-lang.org) programming language.

The outermost layer, consisting of DBs and external interfaces, interacts with
the gateway layer.

Adapter | Gateway
--- | ---
[Oracle](lib/adapter/oracle_adapter.rb) | [Database](lib/gateway/database_gateway.rb)
[AWS SQS](lib/adapter/sqs_adapter.rb) | [Message](lib/gateway/message_gateway.rb)

The idea behind this technical decision is to adhere to the
[open/closed principle](https://en.wikipedia.org/wiki/Open–closed_principle)
where the gateway(s) can accommodate any relevant adapters; for example, a
PostgreSQL adapter for the `database` gateway.

Use cases:

- [Extract](lib/use_case/extract.rb)
- [Transform](lib/use_case/transform.rb)
- [Load](lib/use_case/load.rb)

These use cases depend on the [`base`](lib/use_case/base.rb) use case which
checks the incoming request of the SQS message.
