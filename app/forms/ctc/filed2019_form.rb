module Ctc
  class Filed2019Form < QuestionsForm
    set_attributes_for :intake, :filed_2019

    def save
      @intake.update(attributes_for(:intake))
    end

    def filed_2019?
      filed_2019 != "did_not_file"
    end
  end
end