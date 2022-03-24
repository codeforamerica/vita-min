module Ctc
  class StimulusThreeForm < QuestionsForm
    set_attributes_for :intake, :eip3_entry_method

    validates :eip3_entry_method, acceptance: { accept: 'did_not_receive' }

    def save
      @intake.update(attributes_for(:intake).merge(eip3_amount_received: 0))
    end
  end
end
