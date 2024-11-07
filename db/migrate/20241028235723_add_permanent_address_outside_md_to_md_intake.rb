class AddPermanentAddressOutsideMdToMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :permanent_address_outside_md, :integer, default: 0, null: false
  end
end
