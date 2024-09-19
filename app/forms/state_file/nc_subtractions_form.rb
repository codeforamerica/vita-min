module StateFile
  class NcSubtractionsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :tribal_wages_amount

    validates_numericality_of :tribal_wages, if: -> { tribal_member == "yes" }
    validates :tribal_wages, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { tribal_member == "yes" }

    def save
      if tribal_member == "no"
        @intake.update(tribal_member: "no", tribal_wages: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end

  end
end