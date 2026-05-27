module Hub
  module Admin
    class SmartScanAdminController < Hub::BaseController
      before_action :require_admin
      layout "hub"

      def index
        keys = :id, :name, :type, :show_smartscan_ui
        @vita_partners = VitaPartner.where(type: 'Site').order(:name).pluck(*keys).map{Hash[keys.zip(it)]}
      end

      def create
        ids_to_enable = params.select { |k,v| k.match(/id_/) }.keys.map { it[3..].to_i }
        VitaPartner.where(id: ids_to_enable).update!(show_smartscan_ui: true)
        VitaPartner.where.not(id: ids_to_enable).update!(show_smartscan_ui: false)
      end
    end
  end
end
