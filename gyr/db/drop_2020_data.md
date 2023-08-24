## Running the script
1. Open ssh tunnel to the Aptible database. For example, `demo`:
    ```shell
    aptible db:tunnel vita-min-demo --type postgresql
    ```
1. In a separate terminal, run the SQL script against the desired database. For example, `demo`:
    ```shell
    aptible db:execute vita-min-demo db/drop_2020_data.sql
    ```