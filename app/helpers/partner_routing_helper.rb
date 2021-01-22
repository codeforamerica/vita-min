module PartnerRoutingHelper
  def readable_routing_method(client)
    return nil unless client.routing_method.present?

    I18n.t("hub.clients.fields.routing_methods.#{client.routing_method}")
  end
end