class AddSearchableDataToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :searchable_data, :tsvector
    add_column :intakes, :needs_to_flush_searchable_data_set_at, :datetime
  end
end
