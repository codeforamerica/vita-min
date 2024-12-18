class AddGubernatorialElectionsFundFieldsToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :primary_contribution_gubernatorial_elections, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :spouse_contribution_gubernatorial_elections, :integer, default: 0, null: false
  end
end
