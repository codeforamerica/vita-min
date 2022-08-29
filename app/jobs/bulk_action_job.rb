class BulkActionJob < ApplicationJob
  def perform(task:, user:, bulk_action_notification:, tax_return_selection:, form_params:)
    ActiveRecord::Base.transaction do
      case task
      when :change_organization
        @form = Hub::BulkActionForm.new(tax_return_selection, form_params)
        @clients = tax_return_selection.clients.accessible_to_user(user)
        UpdateClientVitaPartnerService.new(clients: @clients, vita_partner_id: @form.vita_partner_id, change_initiated_by: user).update!
        create_notes!(tax_return_selection, user)
        create_change_org_notifications!(tax_return_selection, user, bulk_action_notification)
        create_outgoing_messages!(tax_return_selection, user)
      end
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

  def create_change_org_notifications!(tax_return_selection, user, notification)
    vita_partner = VitaPartner.accessible_by(Ability.new(user)).find(@form.vita_partner_id)
    if vita_partner.present?
      bulk_update = BulkClientOrganizationUpdate.create!(
        tax_return_selection: tax_return_selection,
        vita_partner: vita_partner
      )
      notification.update(notifiable: bulk_update, user: user)
    end
  end

  def create_outgoing_messages!(tax_return_selection, user)
    if @form.message_body_en.present? || @form.message_body_es.present?
      bulk_client_message = ClientMessagingService.send_bulk_message(
        tax_return_selection,
        user,
        en: { body: @form.message_body_en },
        es: { body: @form.message_body_es },
      )
      if bulk_client_message.present?
        UserNotification.create!(notifiable: bulk_client_message, user: user)
      end
    end
  end
end
