# Overview
The included script
1. Creates an `anon2020` schema to house the anonymized data separately from "production"
   data, which lives in the `public` schema
1. Copies of certain tables (including data) from the `public` schema to the `anon2020` schema
1. Replaces personally identifiable information (PII) with anonymized values

## Running the script
1. Open ssh tunnel to the Aptible database. For example, `demo`:
    ```shell
    aptible db:tunnel vita-min-demo --type postgresql
    ```
1. Run the SQL script against the desired database. For example, `demo`:
    ```shell
    aptible db:execute vita-min-demo db/copy_anonymized_data.sql
    ```
1. Verify the data:
    ```postgresql
    -- Confirm that the schema is created
    select schema_name from information_schema.schemata where schema_name = 'anon2020';

    -- Confirm that the expected tables appear in the new schema
    select table_name from information_schema.tables where table_schema = 'anon2020';

   -- Run some "select" queries against the data in the above tables to verify that everything appears as expected.
    ```