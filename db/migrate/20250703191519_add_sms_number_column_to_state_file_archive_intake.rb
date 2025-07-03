class AddSmsNumberColumnToStateFileArchiveIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intakes, :phone_number, :string
    add_column :state_file_archived_intakes, :contact_preference, :integer, default: 0, null: false
  end
end
