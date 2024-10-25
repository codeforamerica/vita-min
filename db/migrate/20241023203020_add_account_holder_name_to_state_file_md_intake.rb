class AddAccountHolderNameToStateFileMdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :account_holder_name, :string
  end
end
