module StateFile
  class IdGroceryCreditReviewForm < QuestionsForm
    set_attributes_for :intake, :donate_grocery_credit

    validates :donate_grocery_credit, inclusion: { in: %w[yes no], message: :blank }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
