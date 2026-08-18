module TaxReturnCardHelper
  def tax_return_status_to_props(tax_return)
    state = tax_return.current_state.to_sym

    intake = tax_return.intake
    ask_for_answers = state == :intake_in_progress

    if ask_for_answers
      current_step = intake.current_step
      if intake.client&.routing_method_at_capacity?
        # check if the appropriate partner is still at capacity
        PartnerRoutingService.update_intake_partner(intake)

        if intake.client.routing_method_at_capacity?
          current_step = Questions::AtCapacityController.to_path_helper
        else
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
    elsif tax_return.ready_for_8879_signature?(TaxReturn::PRIMARY_SIGNATURE) && signature_documents_ready?(tax_return)
      {
        help_text: t("portal.portal.home.help_text.review_signature_requested_primary"),
        percent_complete: 90,
        button_type: :add_signature_primary,
        call_to_action_text: t("portal.portal.home.calls_to_action.add_signature_primary")
      }
    elsif tax_return.ready_for_8879_signature?(TaxReturn::SPOUSE_SIGNATURE) && signature_documents_ready?(tax_return)
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

  def contact_method_of_last_tax_team_message(intake)
    last = MessagePresenter.grouped_messages(intake.client)&.values&.last&.last
    # ^^^ MessagePresenter.grouped_messages returns a map where a key is a datestamp
    # and a value is an array of messages for that date
    if not last
      return ''
    elsif last.class == OutgoingEmail
      return locale == :es ? 'correo electrónico' : 'email'
    else
      return locale == :es ? 'mensaje de texto' : 'text message'
    end 
  end

  def tax_return_status_to_props_2(tax_return)
    state = tax_return.current_state.to_sym

    intake = tax_return.intake
    ask_for_answers = state == :intake_in_progress

    if ask_for_answers
      current_step = intake.current_step
      if intake.client&.routing_method_at_capacity?
        # check if the appropriate partner is still at capacity
        PartnerRoutingService.update_intake_partner(intake)

        if intake.client.routing_method_at_capacity?
          current_step = Questions::AtCapacityController.to_path_helper
        else
          current_step = Questions::ConsentController.to_path_helper
        end
      end
    end

    if ask_for_answers || state == :intake_needs_doc_help
      {
        badge_text: t('portal.portal2.home.badge.in_progress'),
        help_text: t('portal.portal2.home.help_text.intake_incomplete'),
        button_type: :complete_intake,
        link: state == :intake_needs_doc_help ?
                Portal::UploadDocumentsController.to_path_helper(action: :index) :
                current_step,
        call_to_action_title: t('portal.portal2.home.calls_to_action.finish_intake_title'),
        call_to_action_text: t('portal.portal2.home.calls_to_action.finish_intake'),
        return_status: state
      }
    elsif [:intake_greeter_info_requested,
           :intake_info_requested].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.in_progress'),
        help_text: t('portal.portal2.home.help_text.info_requested'),
        button_type: :add_documents,
        call_to_action_title: t('portal.portal2.home.calls_to_action.add_missing_documents_title'),
        call_to_action_text: t('portal.portal2.home.calls_to_action.add_missing_documents'),
        return_status: state
      }
    elsif [:intake_ready,
           :intake_reviewing,
           :intake_ready_for_call].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.in_progress'),
        help_text: t('portal.portal2.home.help_text.intake_reviewing'),
        button_type: :message_tax_team,
        return_status: state
      }
    elsif [:prep_ready_for_prep, :prep_preparing].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.tax_prep'),
        help_text: t("portal.portal2.home.help_text.tax_prep"),
        button_type: :message_tax_team,
        return_status: state
      }
    elsif [:prep_info_requested].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.tax_prep'),
        help_text: t("portal.portal2.home.help_text.prep_info_requested"),
        button_type: :message_tax_team,
        call_to_action_title: t('portal.portal2.home.calls_to_action.prep_info_requested_title'),
        call_to_action_text:
          t('portal.portal2.home.calls_to_action.prep_info_requested',
            contact_method: contact_method_of_last_tax_team_message(intake)),
        return_status: state
      }
    elsif [:review_ready_for_qr, :review_reviewing, :review_ready_for_call].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.final_check'),
        help_text: t("portal.portal2.home.help_text.review"),
        button_type: :message_tax_team,
        return_status: state
      }
    elsif [:review_info_requested].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.final_check'),
        help_text: t("portal.portal2.home.help_text.review_info_requested"),
        button_type: :message_tax_team,
        call_to_action_title: t('portal.portal2.home.calls_to_action.review_info_requested_title'),
        call_to_action_text:
          t('portal.portal2.home.calls_to_action.review_info_requested',
            contact_method: contact_method_of_last_tax_team_message(intake)),
        return_status: state
      }
    elsif [:file_ready_to_file, :file_accepted, :file_rejected, :file_hold, :file_fraud_hold,
           :file_not_filing, :file_efiled, :file_mailed, :file_needs_review].include?(state)
      {
        badge_text: t('portal.portal2.home.badge.almost_done'),
        help_text: t("portal.portal2.home.help_text.final_steps"),
        button_type: :message_tax_team,
        return_status: state
      }
    elsif state == :review_signature_requested
      signature_type = signature_type_awaited(tax_return)

      {
        badge_text: t('portal.portal2.home.badge.final_check'),
        help_text: t("portal.portal2.home.help_text.signature_requested_#{signature_type}"),
        call_to_action_title: t('portal.portal2.home.calls_to_action.signature_requested_title'),
        call_to_action_text: t('portal.portal2.home.calls_to_action.signature_requested'),
        button_type: :sign_return,
        link: if signature_type == :primary
                portal_tax_return_authorize_signature_path(tax_return_id: tax_return.id)
              else
                portal_tax_return_spouse_authorize_signature_path(tax_return_id: tax_return.id)
              end,
        download_final_tax_documents: true,
        return_status: state
      }
    end
  end

  private

  def signature_type_awaited(tax_return)
    if tax_return.filing_jointly? && tax_return.primary_has_signed_8879? && !tax_return.spouse_has_signed_8879?
      :spouse
    else
      :primary
    end
  end

  def signature_documents_ready?(tax_return)
    has_final_tax_document = tax_return&.final_tax_documents&.any?
    has_8879 = tax_return&.signed_8879s&.any? || tax_return&.unsigned_8879s&.any?

    has_final_tax_document && has_8879
  end
end
