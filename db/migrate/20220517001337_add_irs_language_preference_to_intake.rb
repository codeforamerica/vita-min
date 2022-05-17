class AddIrsLanguagePreferenceToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :irs_language_preference, :integer
  end
end
