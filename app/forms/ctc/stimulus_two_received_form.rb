module Ctc
  class StimulusTwoReceivedForm < QuestionsForm
    set_attributes_for :intake, :eip2_amount_received

    validates_presence_of :eip2_amount_received
    validates :eip2_amount_received, numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:eip2_amount_received].present?
    end
  end
end
