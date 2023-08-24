module Ctc
  class W2sForm < QuestionsForm
    set_attributes_for :intake, :had_w2s

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
