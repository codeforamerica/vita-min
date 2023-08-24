module Ctc
  class AlreadyFiledForm < QuestionsForm
    set_attributes_for :intake, :already_filed

    def save
      @intake.update(attributes_for(:intake))
    end

    def already_filed?
      already_filed == "yes"
    end
  end
end