class InterviewSchedulingForm < QuestionsForm
  LANGUAGES = {
    en: "English",
    fa: "Farsi",
    fr: "French",
    de: "German",
    zh: "Mandarin",
    es: "Spanish",
    ru: "Russian",
  }

  set_attributes_for :intake, :interview_timing_preference, :preferred_interview_language

  def save
    @intake.update(attributes_for(:intake))
  end

  def language_options
    LANGUAGES.values
  end

  def default_option
    LANGUAGES[I18n.locale]
  end
end
