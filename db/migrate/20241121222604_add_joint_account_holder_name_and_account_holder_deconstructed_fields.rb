class AddJointAccountHolderNameAndAccountHolderDeconstructedFields < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :has_joint_account_holder, :integer, default: 0
    add_column :state_file_md_intakes, :joint_account_holder_first_name, :string
    add_column :state_file_md_intakes, :joint_account_holder_last_name, :string
    add_column :state_file_md_intakes, :joint_account_holder_middle_initial, :string
    add_column :state_file_md_intakes, :joint_account_holder_suffix, :string

    add_column :state_file_md_intakes, :account_holder_first_name, :string
    add_column :state_file_md_intakes, :account_holder_last_name, :string
    add_column :state_file_md_intakes, :account_holder_middle_initial, :string
    add_column :state_file_md_intakes, :account_holder_suffix, :string
  end
end
