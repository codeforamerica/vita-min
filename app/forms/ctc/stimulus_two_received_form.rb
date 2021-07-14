module Ctc
  class StimulusTwoReceivedForm < QuestionsForm
    set_attributes_for :intake, :eip_two

    validates_presence_of :eip_two
    validates :eip_two, numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:eip_two].present?
    end
  end
end