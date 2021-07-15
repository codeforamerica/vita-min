class AddCannotClaimMeAsADependentAndMemberOfTheArmedForcesToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :cannot_claim_me_as_a_dependent, :integer, default: 0, null: false
    add_column :intakes, :member_of_the_armed_forces, :integer, default: 0, null: false
  end
end
