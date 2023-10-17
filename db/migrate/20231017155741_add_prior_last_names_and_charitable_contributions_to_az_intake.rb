class AddPriorLastNamesAndCharitableContributionsToAzIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_az_intakes, :prior_last_names, :string
    add_column :state_file_az_intakes, :charitable_cash, :integer
    add_column :state_file_az_intakes, :charitable_noncash, :integer
  end
end
