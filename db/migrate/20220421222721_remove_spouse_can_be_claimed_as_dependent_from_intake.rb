class RemoveSpouseCanBeClaimedAsDependentFromIntake < ActiveRecord::Migration[6.1]
  def change
    remove_column :intakes, :spouse_can_be_claimed_as_dependent
  end
end
