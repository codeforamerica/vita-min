module Hub
  module Admin
    class SmartScanAdminController < Hub::BaseController
      before_action :require_admin
      layout "hub"

      def index
        load_vita_partners
      end

      def create
        displayed_ids = Array(params[:vita_partner_ids]).map(&:to_i)
        enabled_ids = Array(params[:enabled_vita_partner_ids]).map(&:to_i)

        displayed_partners = VitaPartner.where(id: displayed_ids)

        displayed_partners.where(id: enabled_ids).update_all(show_smartscan_ui: true)
        displayed_partners.where.not(id: enabled_ids).update_all(show_smartscan_ui: false)

        redirect_to({ action: :index }, notice: "VitaPartners' SmartScan settings updated successfully")
      end

      private

      def load_vita_partners
        keys = [:id, :name, :type, :show_smartscan_ui]
        @vita_partners = VitaPartner.accessible_by(current_ability).order(:name).pluck(*keys).map { |row| Hash[keys.zip(row)] }
      end
    end
  end
end