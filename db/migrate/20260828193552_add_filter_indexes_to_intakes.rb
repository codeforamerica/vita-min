class AddFilterIndexesToIntakes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :intakes, :locale,                        algorithm: :concurrently
    add_index :intakes, :preferred_interview_language,  algorithm: :concurrently
    add_index :intakes, :state_of_residence,            algorithm: :concurrently
    add_index :intakes, :with_general_navigator,        algorithm: :concurrently, where: "with_general_navigator = true"
    add_index :intakes, :with_incarcerated_navigator,   algorithm: :concurrently, where: "with_incarcerated_navigator = true"
    add_index :intakes, :with_limited_english_navigator, algorithm: :concurrently, where: "with_limited_english_navigator = true"
    add_index :intakes, :with_unhoused_navigator,       algorithm: :concurrently, where: "with_unhoused_navigator = true"
  end
end
