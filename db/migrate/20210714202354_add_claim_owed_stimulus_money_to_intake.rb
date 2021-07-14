class AddClaimOwedStimulusMoneyToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :claim_owed_stimulus_money, :integer, default: 0, null: false
  end
end
