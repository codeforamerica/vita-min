module Ctc
  class SpouseFiled2019Form < QuestionsForm
    set_attributes_for :intake, :spouse_filed_2019

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
