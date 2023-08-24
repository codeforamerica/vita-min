module Ctc
  class AdvanceCtcAmountForm < QuestionsForm
    set_attributes_for :intake, :advance_ctc_amount_received

    validates_presence_of :advance_ctc_amount_received
    validates :advance_ctc_amount_received, gyr_numericality: { only_integer: true }, if: :not_blank?

    def save
      @intake.update(attributes_for(:intake).merge(advance_ctc_entry_method: 'manual_entry'))
    end

    def not_blank?
      attributes_for(:intake)[:advance_ctc_amount_received].present?
    end
  end
end
