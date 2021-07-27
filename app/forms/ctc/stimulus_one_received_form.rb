module Ctc
  class StimulusOneReceivedForm < QuestionsForm
    set_attributes_for :intake, :eip1_amount_received

    validates_presence_of :eip1_amount_received
    validates :eip1_amount_received, numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake).merge(eip1_entry_method: :manual_entry))
    end

    def not_blank?
      attributes_for(:intake)[:eip1_amount_received].present?
    end
  end
end
