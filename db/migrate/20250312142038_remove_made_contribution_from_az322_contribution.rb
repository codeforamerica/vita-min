class RemoveMadeContributionFromAz322Contribution < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :az322_contributions, :made_contribution }
  end
end
