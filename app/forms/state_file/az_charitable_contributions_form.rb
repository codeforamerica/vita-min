module StateFile
  class AzCharitableContributionsForm < QuestionsForm
    set_attributes_for :intake, :charitable_contributions, :charitable_cash, :charitable_noncash

    validates :charitable_contributions, inclusion: { in: %w[yes no], message: :blank }
    validates_numericality_of :charitable_cash, only_integer: true, message: :whole_number, if: -> { charitable_contributions == "yes" }
    validates :charitable_cash, presence: true, numericality: { greater_than_or_equal_to: 0 }, allow_blank: false, if: -> { charitable_contributions == "yes" }
    validates_numericality_of :charitable_noncash, only_integer: true, message: :whole_number, if: -> { charitable_contributions == "yes" }
    validates :charitable_noncash, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 500 }, allow_blank: false, if: -> { charitable_contributions == "yes" }


    def save
      if charitable_contributions == "no"
        @intake.update(charitable_contributions: "no", charitable_cash: nil, charitable_noncash: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end
  end
end