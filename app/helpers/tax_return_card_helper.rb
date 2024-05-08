module TaxReturnCardHelper
  def tax_return_status_to_props(tax_return)
    state = tax_return.current_state.to_sym

    intake = tax_return.intake
    ask_for_answers = state == :intake_in_progress

    if ask_for_answers
      current_step = intake.current_step
      if current_step.in?(Questions::AtCapacityController.all_localized_paths)
        # check if the appropriate partner is still at capacity
        routing_service = PartnerRoutingService.new(
          intake: intake,
          source_param: intake.source,
          zip_code: intake.zip_code,
          )
        intake.client.update(vita_partner: routing_service.determine_partner, routing_method: routing_service.routing_method)

        unless intake.client.routing_method_at_capacity?
          current_step = Questions::ConsentController.to_path_helper
        end
      end
    end

    if ask_for_answers && !current_step&.include?("/documents")
      {
        help_text: t('portal.portal.home.help_text.intake_incomplete'),
        percent_complete: 10,
        button_type: :complete_intake,
        link: current_step,
        call_to_action_text: t('portal.portal.home.calls_to_action.finish_intake')
      }
    elsif ask_for_answers && current_step&.include?("/documents")
      {
        help_text: t('portal.portal.home.help_text.intake_documents_incomplete'),
        percent_complete: 30,
        button_type: :complete_intake_documents,
        link: current_step,
        call_to_action_text: t('portal.portal.home.calls_to_action.add_missing_documents')
      }
    elsif [:file_hold, :file_fraud_hold].include?(state)
      {
        help_text: t("portal.portal.home.help_text.file_hold"),
        button_type: :view_documents
      }
    elsif state == :file_rejected
      {
        help_text: I18n.t('portal.portal.home.help_text.file_rejected'),
        button_type: :view_documents
      }
    elsif state == :file_not_filing
      {
        help_text: t("portal.portal.home.help_text.file_not_filing"),
        button_type: :view_documents,
      }
    elsif state == :file_accepted
      {
        help_text: t("portal.portal.home.help_text.file_accepted", date: tax_return.time_accepted.strftime("%b %-d %Y %l:%M %p")),
        percent_complete: 100,
        button_type: :view_documents,
      }
    elsif [:file_efiled, :file_mailed].include?(state)
      {
        help_text: t("portal.portal.home.help_text.filing"),
        percent_complete: 95,
        button_type: :view_documents,
      }
    elsif tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE)
      {
        help_text: t("portal.portal.home.help_text.review_signature_requested_primary"),
        percent_complete: 90,
        button_type: :add_signature_primary,
        call_to_action_text: t("portal.portal.home.calls_to_action.add_signature_primary")
      }
    elsif tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE)
      {
        help_text: t("portal.portal.home.help_text.review_signature_requested_spouse"),
        percent_complete: 90,
        button_type: :add_signature_spouse,
        call_to_action_text: t("portal.portal.home.calls_to_action.add_signature_spouse")
      }
    elsif state == :review_signature_requested
      {
        help_text: t("portal.portal.home.help_text.prep_ready_for_prep"),
        percent_complete: 90,
        button_type: :view_documents,
      }
    elsif [:file_needs_review, :file_ready_to_file].include?(state)
      {
        help_text: t("portal.portal.home.help_text.filing"),
        percent_complete: 90,
        button_type: :view_documents,
      }
    elsif [:intake_greeter_info_requested, :intake_needs_doc_help, :intake_info_requested, :prep_info_requested, :review_info_requested].include?(state)
      {
        help_text: t('portal.portal.home.help_text.info_requested'),
        percent_complete: {intake_greeter_info_requested: 45, intake_needs_doc_help: 45, intake_info_requested: 45, prep_info_requested: 65, review_info_requested: 85}[state],
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
      }
    elsif [:prep_ready_for_prep, :prep_preparing].include?(state)
      {
        help_text: t("portal.portal.home.help_text.prep_ready_for_prep"),
        percent_complete: 75,
        button_type: :view_documents,
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
