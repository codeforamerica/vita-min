class AddSecurityFieldsToStatefileArchivedIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_archived_intakes, :fake_address_1, :string
    add_column :state_file_archived_intakes, :fake_address_2, :string
    add_column :state_file_archived_intakes, :failed_attempts, :integer,  default: 0, null: false
    add_column :state_file_archived_intakes, :locked_at, :datetime
  end
end
