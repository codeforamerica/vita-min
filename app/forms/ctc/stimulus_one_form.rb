module Ctc
  class StimulusOneForm < QuestionsForm
    set_attributes_for :intake, :eip1_entry_method

    validates :eip1_entry_method, acceptance: { accept: 'did_not_receive' }

    def save
      @intake.update(attributes_for(:intake).merge(eip1_amount_received: 0))
    end
  end
end
