class AddClaimEitcToCtcIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :claim_eitc, :integer, default: 0, null: false
  end
end
