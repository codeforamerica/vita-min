class MakeMdIntakeSsbAmountsNullableWithNoDefault < ActiveRecord::Migration[7.1]
  def change
    change_column :state_file_md_intakes, :primary_ssb_amount, :decimal, precision: 12, scale: 2, null: true, default: nil
    change_column :state_file_md_intakes, :spouse_ssb_amount, :decimal, precision: 12, scale: 2, null: true, default: nil
  end
end
