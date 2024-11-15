class AddDidNotHaveHealthInsuranceToStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :did_not_have_health_insurance, :boolean
  end
end
