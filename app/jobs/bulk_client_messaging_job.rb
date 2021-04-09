class BulkClientMessagingJob < ApplicationJob
  def perform(client_selection, sender, **message_bodies_for_locales)
    locales =  Intake.select(:locale).where(client: client_selection.clients).uniq.pluck(:locale)

    raise ArgumentError.new("Missing message bodies for some client locales") unless locales.compact.sort == message_bodies_for_locales.keys.map(&:to_s).sort

    locales.each do |locale|
      message_body = locale.nil? ? message_bodies_for_locales[:en] : message_bodies_for_locales[locale.to_sym]

      client_selection.clients.where(intake: Intake.where(locale: locale)).find_each do |client|
        ClientMessagingService.send_message_to_all_opted_in_contact_methods(
          client, sender, message_body
        )
      end
    end
  end
end
