# ETL pipeline worker
An SQS queue fetching things from an Oracle DB and putting them into Postgres

## How to install
1. Install [Oracle Instant Client](https://docs.oracle.com/en/database/oracle/r-enterprise/1.5.1/oread/installing-oracle-database-instant-client.html#GUID-A61C2824-B9C7-4344-A7A2-E7FE0F05695D)
2. Define these env vars:
`ORACLE_HOST`, `ORACLE_USER`, `ORACLE_PASSWORD`, 
`POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD,
SQS_QUEUE`, `SQS_REGION`
4. Download this repo and run `bundle install`
5. Run `bundle exec rspec`

### Pre-requisites
- Ruby 2.7.0
- Oracle DB instance running
- Postgres instance running
- SQS queue with instance permissions granted to your instance

## Tips and Tricks

### Connection string to Oracle
export ORACLE_HOST="
(
    DESCRIPTION=(
        ADDRESS=(PROTOCOL=TCP)
        (HOST=`your_host`)
        (PORT=`your_port`)
    )(CONNECT_DATA=(SID=`your_sid`))
)"