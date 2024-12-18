class AddQualifyingChildAttributeToStateFileDependent < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :qualifying_child, :boolean
  end
end