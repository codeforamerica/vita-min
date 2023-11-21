class RemoveClaimedAsDep < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_ny_intakes, :claimed_as_dep
      remove_column :state_file_az_intakes, :claimed_as_dep
    end
  end
end
