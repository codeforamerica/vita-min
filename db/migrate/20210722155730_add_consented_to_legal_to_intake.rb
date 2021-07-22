class AddConsentedToLegalToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :consented_to_legal, :integer, default: 0, null: false
  end
end
