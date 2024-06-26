# Overview
#
# The `analytics` schema with SQL views that contain anonymized data is no longer used by data science
# and can be considered deprecated. Instead, the `read_only_role` is given direct access
# to the required tables. At some point soon we should delete the analytics schema and the code
# below. This does however raise questions about passing non anonymized data to metabase (as the
# read only role has access to non-anonymized data.)
#
#
# See `db/create_analytics_views.sql` for details on the views.

namespace :analytics do
  desc "Prepare database for analytics use with Metabase"

  task drop_views: :environment do |_task|
    ActiveRecord::Base.connection.execute('DROP SCHEMA IF EXISTS analytics CASCADE;')
  end

  task create_views: :environment do |_task|
    ActiveRecord::Base.connection.execute(File.read("db/create_analytics_views.sql"))
    # Complex SQL for CREATE USER IF NOT EXISTS, so that the GRANT commands work
    ["metabase", "read_only_role"].each do |role|
      create_role = <<~SQL
        DO
        $do$
        BEGIN
           IF NOT EXISTS (
              SELECT FROM pg_catalog.pg_roles
              WHERE  rolname = '#{role}') THEN
              CREATE ROLE #{role};
           END IF;
        END
        $do$;
      SQL
      ActiveRecord::Base.connection.execute(create_role)
    end

    # Reset schema permissions
    ActiveRecord::Base.connection.execute('REVOKE ALL ON SCHEMA "analytics" FROM "metabase";')
    ActiveRecord::Base.connection.execute('GRANT USAGE ON SCHEMA "analytics" TO "metabase";')
    ActiveRecord::Base.connection.execute('REVOKE ALL ON SCHEMA "public" FROM "read_only_role";')
    ActiveRecord::Base.connection.execute('GRANT USAGE ON SCHEMA "public" TO "read_only_role";')

    # Reset table access permissions
    ActiveRecord::Base.connection.execute('REVOKE ALL ON ALL TABLES IN SCHEMA "analytics" FROM "metabase";')
    ActiveRecord::Base.connection.execute('GRANT SELECT ON ALL TABLES IN SCHEMA "analytics" TO "metabase";')
    ActiveRecord::Base.connection.execute('REVOKE ALL ON ALL TABLES IN SCHEMA "public" FROM "read_only_role";')
    ActiveRecord::Base.connection.execute('GRANT SELECT ON ALL TABLES IN SCHEMA "public" TO "read_only_role";')
  end

  task delete_metabase_user: :environment do |_task|
    ActiveRecord::Base.connection.execute('REVOKE ALL ON ALL TABLES IN SCHEMA "analytics" FROM "metabase";')
    ActiveRecord::Base.connection.execute('REVOKE ALL ON SCHEMA "analytics" FROM "metabase";')
    ActiveRecord::Base.connection.execute('DROP ROLE IF EXISTS "metabase";')
  end

  task reset_metabase_password: :environment do |_task|
    ActiveRecord::Base.connection.execute('DROP ROLE IF EXISTS "metabase";')
    new_metabase_password = SecureRandom.hex(20)
    ActiveRecord::Base.connection.execute("CREATE USER \"metabase\" WITH PASSWORD #{ActiveRecord::Base.connection.quote(new_metabase_password)};")
    ActiveRecord::Base.connection.execute('GRANT USAGE ON SCHEMA "analytics" TO "metabase";')
    ActiveRecord::Base.connection.execute('GRANT SELECT ON ALL TABLES IN SCHEMA "analytics" TO "metabase";')
    puts("Created new metabase user.")
    puts("Username: metabase")
    puts("Password: #{new_metabase_password}")
    puts("")
    puts("Use that password in the Metabase app configuration. Use the secondary Postgres server as the server.")
  end
end
