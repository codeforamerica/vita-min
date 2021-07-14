module Ctc
  class Filed2020Form < QuestionsForm
    set_attributes_for :intake, :filed_2020

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end