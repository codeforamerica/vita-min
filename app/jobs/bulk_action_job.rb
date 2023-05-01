class BulkActionJob < ApplicationJob
  def perform(task:, user:, tax_return_selection:, form_params:)
    ActiveRecord::Base.transaction do
      @form = Hub::BulkActionForm.new(tax_return_selection, form_params)
      raise ArgumentError unless @form.valid?
      @selection = tax_return_selection
      @clients = tax_return_selection.clients.accessible_to_user(user)
      case task
      when :change_organization
        UpdateClientVitaPartnerService.new(clients: @clients, vita_partner_id: @form.vita_partner_id, change_initiated_by: user).update!
        create_change_org_notifications!(tax_return_selection, user)
      when :change_assignee_and_status
        update_assignee_and_status!(user)
      end
      create_notes!(tax_return_selection, user)
      create_outgoing_messages!(tax_return_selection, user)
    end
  end

  private

  def create_notes!(tax_return_selection, user)
    if @form.note_body.present?
      @clients.find_each do |client|
        client.notes.create!(body: @form.note_body, user: user)
      end
      bulk_note = BulkClientNote.create!(tax_return_selection: tax_return_selection)
      UserNotification.create!(notifiable: bulk_note, user: user)
    end
  end

  def create_change_org_notifications!(tax_return_selection, user)
    vita_partner = VitaPartner.accessible_by(Ability.new(user)).find(@form.vita_partner_id)
    if vita_partner.present?
      bulk_update = BulkClientOrganizationUpdate.create!(
        tax_return_selection: tax_return_selection,
        vita_partner: vita_partner
      )
      UserNotification.create!(notifiable: bulk_update, user: user)
    end
  end

  def create_outgoing_messages!(tax_return_selection, user)
    if @form.message_body_en.present? || @form.message_body_es.present?
      bulk_client_message = BulkClientMessage.create!(tax_return_selection: tax_return_selection, send_only: @form.send_only)

      tax_return_selection.clients.accessible_to_user(user).find_each do |client|
        locale = Hub::ClientsController::HubClientPresenter.new(client).intake.locale || "en"
        args = {
          client: client,
          user: user,
          body: (locale == "en" ? @form.message_body_en : @form.message_body_es)
        }

        unless @form.send_only == "email"
          outgoing_text_message = ClientMessagingService.send_text_message(**args)
          bulk_client_message.outgoing_text_messages << outgoing_text_message if outgoing_text_message
        end

        unless @form.send_only == "text_message"
          outgoing_email = ClientMessagingService.send_email(**args.merge(subject: nil))
          bulk_client_message.outgoing_emails << outgoing_email if outgoing_email
        end
      end
      UserNotification.create!(notifiable: bulk_client_message, user: user)
    end
  end

  def update_assignee_and_status!(user)
    assignment_action =
      case @form.assigned_user_id
      when BulkTaxReturnUpdate::KEEP
        BulkTaxReturnUpdate::KEEP
      when BulkTaxReturnUpdate::REMOVE
        BulkTaxReturnUpdate::REMOVE
      else
        BulkTaxReturnUpdate::UPDATE
      end
    status_action =
      case @form.status
      when BulkTaxReturnUpdate::KEEP
        BulkTaxReturnUpdate::KEEP
      else
        BulkTaxReturnUpdate::UPDATE
      end
    @selection.tax_returns.find_each do |tax_return|
      TaxReturnAssignmentService.new(tax_return: tax_return, assigned_user: @form.assigned_user, assigned_by: user).assign! unless assignment_action == BulkTaxReturnUpdate::KEEP
      unless status_action == BulkTaxReturnUpdate::KEEP
        tax_return.transition_to!(@form.status, initiated_by_user_id: user.id)
        SystemNote::StatusChange.generate!(initiated_by: user, tax_return: tax_return)
      end
    end
    bulk_update = BulkTaxReturnUpdate.create!(
      tax_return_selection: @selection,
      assigned_user: @form.assigned_user,
      state: @form.status,
      data: {
        assigned_user: assignment_action,
        status: status_action
      }
    )
    UserNotification.create!(notifiable: bulk_update, user: user)
  end
end
