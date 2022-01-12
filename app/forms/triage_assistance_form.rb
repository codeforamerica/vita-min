class TriageAssistanceForm < TriageForm
  include FormAttributes

  set_attributes_for :triage, :assistance_in_person, :assistance_chat, :assistance_phone_review_english, :assistance_phone_review_non_english, :assistance_none
  validate :at_least_one_selected

  private

  def at_least_one_selected
    chose_one = assistance_in_person == "yes" ||
      assistance_chat == "yes" ||
      assistance_phone_review_english == "yes" ||
      assistance_phone_review_non_english == "yes" ||
      assistance_none == "yes"
    errors.add(:assistance_none, I18n.t("general.please_select_at_least_one_option")) unless chose_one
  end
end
