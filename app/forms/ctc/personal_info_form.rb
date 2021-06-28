module Ctc
  class PersonalInfoForm < QuestionsForm
    set_attributes_for :intake, :preferred_name, :timezone

    validates :preferred_name, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end