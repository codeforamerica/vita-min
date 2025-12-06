module Hub
  module BulkActions
    class BaseBulkActionsController < Hub::BaseController
      load_and_authorize_resource :tax_return_selection
      before_action :load_clients, :load_template_variables
      before_action :load_edit_form, only: :edit
      layout "hub"

      def edit; end

      private

      def load_edit_form
        @form = BulkActionForm.new(@tax_return_selection)
      end

      def load_clients
        @clients = @tax_return_selection.clients.accessible_by(current_ability)
      end

      def load_template_variables
        insufficient_contact_ids = @clients.with_insufficient_contact_info.pluck(:id)
        @locale_counts = @clients.where.not(id: insufficient_contact_ids).locale_counts
        @no_contact_info_count = insufficient_contact_ids.size
      end
    end
  end
end
