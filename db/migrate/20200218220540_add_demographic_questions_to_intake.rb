class AddDemographicQuestionsToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :demographic_questions_opt_in, :integer, default: 0, null: false
    add_column :intakes, :demographic_english_conversation, :integer, default: 0, null: false
    add_column :intakes, :demographic_english_reading, :integer, default: 0, null: false
    add_column :intakes, :demographic_disability, :integer, default: 0, null: false
    add_column :intakes, :demographic_veteran, :integer, default: 0, null: false

    add_column :intakes, :demographic_primary_american_indian_alaska_native, :boolean
    add_column :intakes, :demographic_primary_black_african_american, :boolean
    add_column :intakes, :demographic_primary_native_hawaiian_pacific_islander, :boolean
    add_column :intakes, :demographic_primary_asian, :boolean
    add_column :intakes, :demographic_primary_white, :boolean
    add_column :intakes, :demographic_primary_prefer_not_to_answer_race, :boolean

    add_column :intakes, :demographic_spouse_american_indian_alaska_native, :boolean
    add_column :intakes, :demographic_spouse_black_african_american, :boolean
    add_column :intakes, :demographic_spouse_native_hawaiian_pacific_islander, :boolean
    add_column :intakes, :demographic_spouse_asian, :boolean
    add_column :intakes, :demographic_spouse_white, :boolean
    add_column :intakes, :demographic_spouse_prefer_not_to_answer_race, :boolean

    add_column :intakes, :demographic_primary_ethnicity, :integer, default: 0, null: false
    add_column :intakes, :demographic_spouse_ethnicity, :integer, default: 0, null: false
  end
end
