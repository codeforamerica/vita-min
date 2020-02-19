class DemographicPrimaryRaceForm < QuestionsForm
  set_attributes_for :intake,
                     :demographic_primary_american_indian_alaska_native,
                     :demographic_primary_black_africa_american,
                     :demographic_primary_native_hawaiian_pacific_islander,
                     :demographic_primary_asian,
                     :demographic_primary_white,
                     :demographic_primary_prefer_not_to_answer_race

  def save
    @intake.update(attributes_for(:intake))
  end
end