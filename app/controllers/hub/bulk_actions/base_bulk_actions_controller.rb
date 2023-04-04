module Hub
  module BulkActions
    class BaseBulkActionsController < ApplicationController
      include AccessControllable

      layout "hub"

      before_action :require_sign_in
      load_and_authorize_resource :tax_return_selection
      before_action :load_clients, :load_template_variables
      before_action :load_edit_form, only: :edit

      def edit; end

      private

      def load_edit_form
        @form = BulkActionForm.new(@tax_return_selection)
      end

      def load_clients
        @clients = @tax_return_selection.clients.accessible_by(current_ability)
      end

      def load_template_variables
        @inaccessible_client_count = @tax_return_selection.clients.where.not(id: @clients).size
        @locale_counts = @clients.where.not(id: @clients.with_insufficient_contact_info).locale_counts
        @no_contact_info_count = @clients.with_insufficient_contact_info.size
      end
    end
  end
end
