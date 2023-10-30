class StateIntakeDefaultToClaimedAsDepUnfilled < ActiveRecord::Migration[7.1]
  def change
    change_column_default :state_file_az_intakes, :claimed_as_dep, from: nil, to: 0
    change_column_default :state_file_ny_intakes, :claimed_as_dep, from: nil, to: 0
  end
end
