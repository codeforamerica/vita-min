class ItemizingForm < QuestionsForm
  set_attributes_for :intake, :wants_to_itemize

  def save
    if wants_to_itemize == "no"
      @intake.update(attributes_for(:intake).merge(gated_answers))
    else
      @intake.update(attributes_for(:intake))
    end
  end

  private

  def gated_answers
    Hash[gated_questions.map { |question| [question, "no"] }]
  end

  def gated_questions
    [:paid_medical_expenses, :had_gambling_income, :paid_school_supplies, :paid_local_tax, :had_local_tax_refund]
  end
end