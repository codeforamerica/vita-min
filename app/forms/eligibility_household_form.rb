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
  validates :had_qualifying_child_under_6, inclusion: { in: %w[yes no] }, if: :uses_under_6_question?
  validates :had_qualifying_child_under_17, inclusion: { in: %w[yes no] }, unless: :uses_under_6_question?

  def save
    @intake.update(attributes_for(:intake))
  end

  private

  def uses_under_6_question?
    %w[CO NJ].include?(state_of_residence)
  end

  def clear_inapplicable_child_answer
    if uses_under_6_question?
      self.had_qualifying_child_under_17 = :unfilled
    else
      self.had_qualifying_child_under_6 = :unfilled
    end
  end
end