module Ctc
  class Filed2019Form < QuestionsForm
    set_attributes_for :intake, :filed_2019

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end