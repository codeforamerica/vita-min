class AddSpouseCanBeClaimedAsDependentToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :spouse_can_be_claimed_as_dependent, :integer, default: 0
  end
end
