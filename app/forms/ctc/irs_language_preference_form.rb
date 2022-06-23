module Ctc
  class IrsLanguagePreferenceForm < QuestionsForm
    set_attributes_for :intake, :irs_language_preference
    validates :irs_language_preference, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
