class AddNavigatorsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :with_general_navigator, :boolean, default: :false
    add_column :intakes, :with_incarcerated_navigator, :boolean, default: :false
    add_column :intakes, :with_limited_english_navigator, :boolean, default: :false
    add_column :intakes, :with_unhoused_navigator, :boolean, default: :false
  end
end
