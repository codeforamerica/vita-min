module Ctc
  class MainHomeForm < QuestionsForm
    include InitialCtcFormAttributes

    set_attributes_for :intake, :home_location
    validates :home_location, presence: true

    def save
      initial_intake_save
      @intake.update(attributes_for(:intake))
    end
  end
end
