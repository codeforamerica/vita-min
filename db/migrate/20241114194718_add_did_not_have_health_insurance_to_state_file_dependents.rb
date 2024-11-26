class AddDidNotHaveHealthInsuranceToStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :md_did_not_have_health_insurance, :integer, null: false, default: 0
  end
end
