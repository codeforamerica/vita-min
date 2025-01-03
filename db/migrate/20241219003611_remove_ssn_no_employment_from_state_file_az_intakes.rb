class RemoveSsnNoEmploymentFromStateFileAzIntakes < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :state_file_az_intakes, :ssn_no_employment }
  end
end
