class BulkClientMessagingJob < ApplicationJob
  def perform(client_selection, sender, **message_bodies_for_locales)
    @locales =  Intake.where(client: client_selection.clients).pluck(:locale).uniq

    raise ArgumentError.new("Missing message bodies for some client locales") unless sorted_locales_without_nil == message_bodies_for_locales.keys.map(&:to_s).sort

    @locales.each do |locale|
      message_body = locale.nil? ? message_bodies_for_locales[:en] : message_bodies_for_locales[locale.to_sym]

      client_selection.clients.accessible_to_user(sender).where(intake: Intake.where(locale: locale)).find_each do |client|
        ClientMessagingService.send_message_to_all_opted_in_contact_methods(
          client, sender, message_body
        )
      end
    end
  end

  private

  def sorted_locales_without_nil
    @locales.compact.blank? ? ["en"] : @locales.compact.sort
  end
end
