class InterviewSchedulingForm < QuestionsForm
  set_attributes_for :intake, :interview_timing_preference, :preferred_interview_language

  def save
    @intake.update(attributes_for(:intake))
  end

  def language_options
    I18n.backend.translations[I18n.locale][:general][:language].invert
  end

  def self.existing_attributes(intake)
    intake.preferred_interview_language ||= I18n.locale
    HashWithIndifferentAccess.new(intake.attributes)
  end
end
