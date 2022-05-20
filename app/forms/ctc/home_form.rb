module Ctc
  class HomeForm < QuestionsForm
    set_attributes_for :intake, :home_location

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
