class AddHealthInsuranceFlagsToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :primary_did_not_have_health_insurance, :boolean
    add_column :state_file_md_intakes, :spouse_did_not_have_health_insurance, :boolean
  end
end
