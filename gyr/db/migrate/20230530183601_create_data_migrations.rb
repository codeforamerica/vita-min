class CreateDataMigrations < ActiveRecord::Migration[7.0]
  def change
    unless table_exists?(:data_migrations)
      create_table :data_migrations, primary_key: 'version', id: :string
    end
  end
end
