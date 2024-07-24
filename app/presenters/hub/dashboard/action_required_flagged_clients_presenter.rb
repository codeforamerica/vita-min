module Hub
  module Dashboard
    class ActionRequiredFlaggedClientsPresenter
      def initialize(clients, selected_orgs_and_sites)
        @clients = clients
        @selected_orgs_and_sites = selected_orgs_and_sites
      end

      def flagged_clients
        @flagged_clients = @clients.where.not(flagged_at: nil).where(vita_partner: @selected_orgs_and_sites)
      end
    end
  end
end