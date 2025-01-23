class Add1099RSubtractionFollowUps < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md1099_r_followups, :income_source, :integer, default: 0, null: false
    add_column :state_file_md1099_r_followups, :service_type, :integer, default: 0, null: false
    add_column :state_file_md_intakes, :primary_disabled, :integer, default: 0, null: false
    add_column :state_file_md_intakes, :secondary_disabled, :integer, default: 0, null: false
  end
end
