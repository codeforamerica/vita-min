class CreateStateFileW2s < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_w2s do |t|
      t.timestamps
      t.references :state_file_intake, polymorphic: true, index: true
      t.integer :w2_index
      t.string :employer_state_id_num
      t.decimal :state_wages_amt, precision: 12, scale: 2
      t.decimal :state_income_tax_amt, precision: 12, scale: 2
      t.decimal :local_wages_and_tips_amt, precision: 12, scale: 2
      t.decimal :local_income_tax_amt, precision: 12, scale: 2
      t.string :locality_nm
    end
  end
end
