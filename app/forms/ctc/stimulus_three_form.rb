module Ctc
  class StimulusThreeForm < QuestionsForm
    set_attributes_for :intake, :eip3_amount_received

    validates_presence_of :eip3_amount_received
    validates :eip3_amount_received, gyr_numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:eip3_amount_received].present?
    end
  end
end
