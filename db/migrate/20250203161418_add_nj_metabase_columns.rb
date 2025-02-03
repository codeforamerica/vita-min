class AddNjMetabaseColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :NJ1040_LINE_7_SELF, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_7_SPOUSE, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_12_COUNT, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_15, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_16A, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_16B, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_29, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_31, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_41, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_42, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_43, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_51, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_56, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_58, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_58_IRS, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_59, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_61, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_64, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_65, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :NJ1040_LINE_65_DEPENDENTS, :integer, default: 0, null: false
  end
end
