module Hub
  module TaxReturns
    class CertificationsController < Hub::BaseController
      load_and_authorize_resource :tax_return, parent: false

      def update
        @tax_return.update(tax_return_params)
        params[:tax_return_id] = nil
        next_path = params[:next].present? && !params[:next].include?("//") && params[:next]
        redirect_to next_path || hub_client_path(id: @tax_return.client.id)
      end

      def tax_return_params
        params.permit(:certification_level)
      end
    end
  end
end