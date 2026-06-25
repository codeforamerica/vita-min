class EligibilityHouseholdForm < QuestionsForm
  set_attributes_for(
    :intake,
    :triage_filing_status,
    :state_of_residence,
    :had_qualifying_child_under_17,
    :had_qualifying_child_under_6
  )

  before_validation :clear_inapplicable_child_answer

  validates :triage_filing_status, presence: true
  validates :state_of_residence, presence: true
  validates :had_qualifying_child_under_6, inclusion: { in: %w[yes no] }, if: -> { state_of_residence == "NJ" }
  validates :had_qualifying_child_under_17, inclusion: { in: %w[yes no] }, if: -> { state_of_residence == "CO" }

  def save
    @intake.update(attributes_for(:intake))
  end

  private

  def clear_inapplicable_child_answer
    self.had_qualifying_child_under_17 = "unfilled" unless state_of_residence == "CO"
    self.had_qualifying_child_under_6 = "unfilled" unless state_of_residence == "NJ"
  end
end