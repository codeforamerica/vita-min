module StateFile
  class AzCharitableContributionsForm < QuestionsForm
    set_attributes_for :intake, :charitable_contributions, :charitable_cash_amount, :charitable_noncash_amount

    validates :charitable_contributions, inclusion: { in: %w[yes no], message: :blank }
    validates :charitable_cash_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }, allow_blank: false, if: -> { charitable_contributions == "yes" }
    validates :charitable_noncash_amount, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 500 }, allow_blank: false, if: -> { charitable_contributions == "yes" }

    def save
      if charitable_contributions == "no"
        @intake.update(charitable_contributions: "no", charitable_cash_amount: nil, charitable_noncash_amount: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end
  end
end