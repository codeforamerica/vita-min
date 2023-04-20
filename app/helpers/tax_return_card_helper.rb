module TaxReturnCardHelper
  def tax_return_status_to_fields(tax_return)
    state = tax_return.current_state.to_sym
    state_index = TaxReturnStateMachine.states.index(tax_return.current_state)

    if @ask_for_answers && !@current_step&.include?("/documents")
      {
        help_text: t('portal.portal.home.help_text.intake_incomplete'),
        percent_complete: 10,
        button_type: :complete_intake,
        call_to_action_text: t('portal.portal.home.calls_to_action.finish_intake')
      }
    elsif @ask_for_answers && @current_step&.include?("/documents")
      {
        help_text: t('portal.portal.home.help_text.intake_documents_incomplete'),
        percent_complete: 30,
        button_type: :complete_intake_documents,
        call_to_action_text: t('portal.portal.home.calls_to_action.add_missing_documents')
      }
    elsif [:file_hold, :file_fraud_hold].include?(state)
      {
        help_text: t("portal.portal.home.waiting_state.tax_return.file_hold")
        # TODO: percentage and CTA based on previous state
      }
    elsif state == :file_not_filing
      {
        help_text: t("portal.portal.home.waiting_state.tax_return.file_not_filing"),
        button_type: :view_documents,
      }
    elsif state == :file_accepted
      transition = tax_return.tax_return_transitions.where(to_state: :file_accepted, most_recent: true).first
      {
        help_text: t("portal.portal.home.help_text.file_accepted", date: transition.created_at.strftime("%b %-d %Y %l:%M %p")),
        percent_complete: 100,
        button_type: :view_documents,
      }
    elsif [:file_efiled, :file_mailed].include?(state)
      {
        help_text: t("portal.portal.home.help_text.filing"),
        percent_complete: 95,
        button_type: :view_documents,
      }
    elsif [:file_needs_review, :file_ready_to_file].include?(state)
      {
        help_text: t("portal.portal.home.help_text.filing"),
        percent_complete: 90,
        button_type: :view_documents,
      }
    elsif state == :review_signature_requested && tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)
      {
        help_text: t("portal.portal.home.progress_state.tax_return.review_signature_requested_primary"),
        percent_complete: 90,
        button_type: :add_signature_primary,
        call_to_action_text: t("portal.portal.home.calls_to_action.add_signature_primary")
      }
    elsif state == :review_signature_requested && tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)
      {
        help_text: t("portal.portal.home.progress_state.tax_return.review_signature_requested_spouse"),
        percent_complete: 90,
        button_type: :add_signature_spouse,
        call_to_action_text: t("portal.portal.home.calls_to_action.add_signature_spouse")
      }
    elsif [:intake_needs_doc_help, :intake_info_requested, :prep_info_requested, :review_info_requested].include?(state)
      {
        help_text: t('portal.portal.home.help_text.info_requested'),
        percent_complete: {intake_needs_doc_help: 45, intake_info_requested: 45, prep_info_requested: 65, review_info_requested: 85}[state],
        button_type: :add_missing_documents,
        call_to_action_text: t('portal.portal.home.calls_to_action.add_missing_documents')
      }
    elsif state == :review_ready_for_call
      {
        help_text: t('portal.portal.home.help_text.review_ready_for_call'),
        percent_complete: 85,
        button_type: :view_documents,
      }
    elsif [:review_ready_for_qr, :review_reviewing].include?(state)
      {
        help_text: t("portal.portal.home.help_text.review_reviewing"),
        percent_complete: 80,
        button_type: :view_documents,
        call_to_action_text: t("portal.portal.home.calls_to_action.preparing_your_return")
      }
    elsif [:prep_ready_for_prep, :prep_preparing].include?(state)
      {
        help_text: t("portal.portal.home.help_text.prep_ready_for_prep"),
        percent_complete: 75,
        button_type: :view_documents,
        call_to_action_text: t("portal.portal.home.calls_to_action.preparing_your_return")
      }
    elsif state == :intake_ready_for_call
      {
        help_text: t("portal.portal.home.help_text.intake_ready_for_call"),
        percent_complete: 50,
        button_type: :view_documents,
      }
    elsif [:intake_ready, :intake_reviewing].include?(state)
      {
        help_text: t("portal.portal.home.help_text.intake_ready"),
        percent_complete: 45,
        button_type: :view_documents,
      }
    end
  end
end
