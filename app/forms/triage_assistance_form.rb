class TriageAssistanceForm < TriageForm
  include FormAttributes

  set_attributes_for :triage, :assistance_in_person, :assistance_chat, :assistance_phone_review_english, :assistance_phone_review_non_english
  set_attributes_for :misc, :assistance_none

  validates :assistance_none, at_least_one_or_none_of_the_above_selected: true

  def at_least_one_selected
    assistance_in_person == "yes" ||
      assistance_chat == "yes" ||
      assistance_phone_review_english == "yes" ||
      assistance_phone_review_non_english == "yes"
  end
end
