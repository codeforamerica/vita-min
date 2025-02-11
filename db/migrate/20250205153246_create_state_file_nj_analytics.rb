class CreateStateFileNjAnalytics < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_nj_analytics do |t|
      t.belongs_to :state_file_nj_intake, null: false
      t.boolean :claimed_as_dep
      t.boolean :NJ1040_LINE_7_SELF
      t.boolean :NJ1040_LINE_7_SPOUSE
      t.boolean :NJ1040_LINE_8_SELF
      t.boolean :NJ1040_LINE_8_SPOUSE
      t.integer :NJ1040_LINE_12_COUNT, default: 0, null: false
      t.integer :NJ1040_LINE_15, default: 0, null: false
      t.integer :NJ1040_LINE_16A, default: 0, null: false
      t.integer :NJ1040_LINE_16B, default: 0, null: false
      t.integer :NJ1040_LINE_29, default: 0, null: false
      t.integer :NJ1040_LINE_31, default: 0, null: false
      t.integer :NJ1040_LINE_41, default: 0, null: false
      t.integer :NJ1040_LINE_42, default: 0, null: false
      t.integer :NJ1040_LINE_43, default: 0, null: false
      t.integer :NJ1040_LINE_51, default: 0, null: false
      t.integer :NJ1040_LINE_56, default: 0, null: false
      t.integer :NJ1040_LINE_58, default: 0, null: false
      t.boolean :NJ1040_LINE_58_IRS
      t.integer :NJ1040_LINE_59, default: 0, null: false
      t.integer :NJ1040_LINE_61, default: 0, null: false
      t.integer :NJ1040_LINE_64, default: 0, null: false
      t.integer :NJ1040_LINE_65, default: 0, null: false
      t.integer :NJ1040_LINE_65_DEPENDENTS, default: 0, null: false
      t.timestamps
    end
  end
end
