class AddFilingStatusToTriages < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.connection.execute("TRUNCATE triages RESTART IDENTITY")
    add_column :triages, :filing_status, :integer, default: 0, null: false
    change_column :triages, :income_level, :integer, default: 0, null: false
    change_column :triages, :doc_type, :integer, default: 0, null: false
    change_column :triages, :id_type, :integer, default: 0, null: false
  end

  def down
    remove_column :triages, :filing_status
    change_column :triages, :income_level, :integer, default: nil, null: true
    change_column :triages, :doc_type, :integer, default: nil, null: true
    change_column :triages, :id_type, :integer, default: nil, null: true
  end
end
