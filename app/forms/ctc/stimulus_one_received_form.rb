module Ctc
  class StimulusOneReceivedForm < QuestionsForm
    set_attributes_for :intake, :eip_one

    validates_presence_of :eip_one
    validates :eip_one, numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:eip_one].present?
    end
  end
end