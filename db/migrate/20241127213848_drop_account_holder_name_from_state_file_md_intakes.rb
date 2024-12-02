class DropAccountHolderNameFromStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_md_intakes, :account_holder_name
    end
  end
end
