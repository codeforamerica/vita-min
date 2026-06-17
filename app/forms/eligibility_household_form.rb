class EligibilityHouseholdForm < QuestionsForm
  set_attributes_for(
    :intake,
    :triage_filing_status,
    :state_of_residence, #will this override the personal info form, or are we taking it out of there
    :had_qualifying_child_under_17
    )

  # validations? presence of?

  def save
    @intake.update(attributes_for(:intake))
  end

end
