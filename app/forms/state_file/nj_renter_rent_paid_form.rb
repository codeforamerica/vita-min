module StateFile
  class NjRenterRentPaidForm < QuestionsForm
    set_attributes_for :intake,
                       :rent_paid

    validates :rent_paid, presence: true
    validates_numericality_of :rent_paid, only_integer: true, message: :round_to_whole_number, if: -> { rent_paid.present? }
    validates :rent_paid, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { rent_paid.present? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end