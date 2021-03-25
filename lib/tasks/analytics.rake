# Overview
#
# We create an `analytics` schema with SQL VIEWs that contain anonymized data.
# This keeps them separate from "production" data, which lives in the
# `public` schema.
#
# We can grant Metabase read access to these `analytics` views and be confident
# Metabase has no access to our most sensitive information.
#
# See `db/create_analytics_views.sql` for details on the views.

namespace :analytics do
  desc "Prepare database for analytics use with Metabase"
  task create_views: :environment do |_task|
    ActiveRecord::Base.connection.execute(File.read("db/create_analytics_views.sql"))
    ActiveRecord::Base.connection.execute('GRANT USAGE ON SCHEMA "analytics" TO "metabase";')
    ActiveRecord::Base.connection.execute('GRANT SELECT ON ALL TABLES IN SCHEMA "analytics" TO "metabase";')
  end

  task delete_metabase_user: :environment do |_task|
    ActiveRecord::Base.connection.execute('REVOKE ALL ON ALL TABLES IN SCHEMA "analytics" FROM "metabase";')
    ActiveRecord::Base.connection.execute('REVOKE ALL ON SCHEMA "analytics" FROM "metabase";')
    ActiveRecord::Base.connection.execute('DROP ROLE IF EXISTS "metabase";')
  end

  task create_metabase_user: :environment do |_task|
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
