module Ctc
  class StimulusTwoForm < QuestionsForm
    set_attributes_for :intake, :eip2_entry_method

    validates :eip2_entry_method, acceptance: { accept: 'did_not_receive' }

    def save
      @intake.update(attributes_for(:intake).merge(eip2_amount_received: 0))
    end
  end
end
