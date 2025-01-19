class DemographicPrimaryRaceForm < QuestionsForm
  set_attributes_for :intake,
                     :demographic_primary_american_indian_alaska_native,
                     :demographic_primary_black_african_american,
                     :demographic_primary_mena,
                     :demographic_primary_hispanic_latino,
                     :demographic_primary_native_hawaiian_pacific_islander,
                     :demographic_primary_asian,
                     :demographic_primary_white,
                     :demographic_primary_prefer_not_to_answer_race

  def save
    attributes = attributes_for(:intake)
    if attributes[:demographic_primary_prefer_not_to_answer_race] == "true"
      attributes.keys.map do |attribute_name|
        attributes[attribute_name] = "0" unless attribute_name == :demographic_primary_prefer_not_to_answer_race
        hash
      end
    end
    @intake.update(attributes)
  end
end
