class InterviewSchedulingForm < QuestionsForm
  set_attributes_for :intake,
                     :interview_timing_preference,
                     :preferred_interview_language,
                     :preferred_written_language

  def save
    preferred_written_language_not_english = preferred_written_language == "en" ? 'no' : 'yes'
    @intake.update(receive_written_communication: preferred_written_language_not_english)
    @intake.update(attributes_for(:intake))
  end

  def language_options
    I18n.backend.translations[I18n.locale][:general][:language_options].invert
  end

  def written_language_options
    I18n.backend.translations[I18n.locale][:general][:written_language_options].invert
  end

  def self.existing_attributes(intake)
    intake.preferred_interview_language ||= I18n.locale
    intake.preferred_written_language ||= I18n.locale
    HashWithIndifferentAccess.new(intake.attributes)
  end
end
