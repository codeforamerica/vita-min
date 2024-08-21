module Hub
  module Dashboard
    class ServiceLevelAgreementsNotificationsPresenter
      def initialize(clients, selected_orgs_and_sites)
        @clients = clients
        @selected_orgs_and_sites = selected_orgs_and_sites
      end

      def approaching_sla_clients
        @approaching_sla_clients ||= @clients.select("clients.vita_partner_id, COUNT(clients.id) AS number_of_clients")
                                             .sla_tracked
                                             .where(vita_partner_id: @selected_orgs_and_sites.map(&:id))
                                             .where(last_outgoing_communication_at: 6.business_days.ago..4.business_days.ago)
                                             .group("clients.vita_partner_id")
      end

      def approaching_sla_clients_count
        approaching_sla_clients.map { |result| result.number_of_clients }.sum
      end

      def approaching_sla_client_ids
        approaching_sla_clients.map(&:vita_partner_id)
      end

      def breached_sla_clients
        @breached_sla_clients ||= @clients.select("clients.vita_partner_id, COUNT(clients.id) AS number_of_clients")
                                             .sla_tracked
                                             .where(vita_partner_id: @selected_orgs_and_sites.map(&:id))
                                             .where("last_outgoing_communication_at < ?", 6.business_days.ago)
                                             .group("clients.vita_partner_id")
      end

      def breached_sla_clients_count
        breached_sla_clients.map { |result| result.number_of_clients }.sum
      end

      def breached_sla_client_ids
        breached_sla_clients.map(&:vita_partner_id)
      end
    end
  end
end