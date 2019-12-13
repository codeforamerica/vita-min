class EnablePostgis < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS postgis;"
  end

  def down
    execute "DROP EXTENSION IF EXISTS postgis;"
  end
end
