# ETL Pipeline Setup - MacOS

## Prerequisites

Ensure you have the following installed:

- [Docker](https://www.docker.com)
  - to run the end-to-end and integration tests
- [Git](https://git-scm.com) (_optional_)
- [Oracle Instant Client - v12.2.0.1.0 (64-bit)](https://www.oracle.com/database/technologies/instant-client/macos-intel-x86-downloads.html)
  - Basic Light Package -> `oic.zip`
  - SQL*Plus Package -> `osqlplus.zip`
  - SDK Package -> `osdk.zip`
- [Ruby v2.7.0](https://www.ruby-lang.org)
  - [Bundler](https://bundler.io)
    - to install dependencies found in `Gemfile`

_Note: Remember to rename the Oracle Instant Client ZIP files as shown above._

## Install

Use `Git` to clone the repository, or alternatively download ZIP. We will use
`Git`.

```shell script
$ git clone git@github.com:communitiesuk/epb-etl.git
$ cd epb-etl
```

Create a `Darwin` subdirectory in the `vendor/oracle` directory. This is where
the Oracle Instant Client will be installed.

```shell script
$ mkdir -p vendor/oracle/Darwin
```

Move the downloaded Oracle Instant Client ZIP files to `vendor/oracle/Darwin`.

The folder structure should now look like this:

```shell script
.
└── vendor
    └── oracle
        └── Darwin
            ├── oic.zip
            ├── osdk.zip
            └── osqlplus.zip
```

Ensuring Ruby version `2.7.0` is installed, run the following command.

```shell script
$ make install
# -> Done installing
```
