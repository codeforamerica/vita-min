module StateFile
  class IdGroceryCreditReviewForm < QuestionsForm
    set_attributes_for :intake, :donate_grocery_credit

    validates :donate_grocery_credit, inclusion: { in: %w[yes no], message: :blank }

  end
end
