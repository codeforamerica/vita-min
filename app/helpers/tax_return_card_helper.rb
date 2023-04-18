module TaxReturnCardHelper
  def tax_return_status_to_fields(tax_return)
    state = tax_return.current_state.to_sym
    state_index = TaxReturnStateMachine.states.index(tax_return.current_state)

    if state == :file_hold
      {
        help_text: t("portal.portal.home.waiting_state.tax_return.file_hold")
      }
    elsif state == :file_not_filing
      {
        help_text: t("portal.portal.home.waiting_state.tax_return.file_not_filing")
      }
    elsif state == :file_accepted
      {
        help_text: t("portal.portal.home.help_text.file_accepted"),
        percent_complete: 100,
        button_type: :view_documents,
        call_to_action_text: "you did it"
      }
    elsif [:file_efiled, :file_mailed].include?(state)
      {

      }
    elsif [:intake_info_requested, :prep_info_requested, :review_info_requested].include?(state)
      {
        help_text: t('portal.portal.home.help_text.info_requested'),
        percent_complete: {intake_info_requested: 45, prep_info_requested: 65, review_info_requested: 85}[state],
        button_type: :add_missing_documents,
        call_to_action_text: t('portal.portal.home.calls_to_action.add_missing_documents')
      }
    elsif state_index >= TaxReturnStateMachine.states.index("review_signature_requested")
      {
        help_text: t("portal.portal.home.progress_state.tax_return.completed_qr", year: tax_return.year),
      }
    elsif state == :review_ready_for_call
      {
        help_text: t('portal.portal.home.help_text.review_ready_for_call', year: tax_return.year),
        percent_complete: 85,
        button_type: :view_documents,
        call_to_action_text: t("portal.portal.home.calls_to_action.schedule_initial_review_call")
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
        call_to_action_text: t("portal.portal.home.calls_to_action.schedule_initial_review_call")
      }
    elsif [:intake_ready, :intake_reviewing].include?(state)
      {
        help_text: t("portal.portal.home.help_text.intake_ready"),
        percent_complete: 45,
        button_type: :view_documents,
        call_to_action_text: t("portal.portal.home.calls_to_action.schedule_initial_review_call")
      }
    end
    # if tax_return.current_state == 'intake_reviewing'
    #   {
    #     help_text: "Your tax team is waiting for an initial review with you.",
    #     percent_complete: 60,
    #
    #   }
    # else
    #   {
    #     help_text: "We are waiting for a final signature from you.",
    #     percent_complete: 95,
    #     call_to_action_text: "Please add your final signature to your tax return",
    #     button_text: "Add final signature",
    #     button_url: portal_tax_return_authorize_signature_path(tax_return_id: tax_return.id),
    #   }
    # end
  end
end
