class DemographicSpouseRaceForm < QuestionsForm
  set_attributes_for :intake,
                     :demographic_spouse_american_indian_alaska_native,
                     :demographic_spouse_black_african_american,
                     :demographic_spouse_mena,
                     :demographic_spouse_hispanic_latino,
                     :demographic_spouse_native_hawaiian_pacific_islander,
                     :demographic_spouse_asian,
                     :demographic_spouse_white,
                     :demographic_spouse_prefer_not_to_answer_race
  def save
    attributes = attributes_for(:intake)
    if attributes[:demographic_primary_prefer_not_to_answer_race] == "true"
      attributes.keys.map do |attribute_name|
        attributes[attribute_name] = "0" unless attribute_name == :demographic_spouse_prefer_not_to_answer_race
        hash
      end
    end
    @intake.update(attributes)
  end
end
