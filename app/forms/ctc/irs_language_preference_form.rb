module Ctc
  class IrsLanguagePreferenceForm < QuestionsForm
    set_attributes_for :misc, :irs_language_preference
    validates :irs_language_preference, presence: true

    def save
      @intake.update(irs_language_preference: IrsLanguages.key_for_name(irs_language_preference))
    end
  end
end
