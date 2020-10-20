module CaseManagement
  class TaxReturnsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client

    layout "admin"

    def edit; end

    def update
      return render :edit unless @tax_return.update(tax_return_params)

      success_message = I18n.t(
        "case_management.tax_returns.update.flash_success",
        assignee_name: @tax_return.assigned_user.name,
        client_name: @client.preferred_name,
        tax_year: @tax_return.year,
      )
      redirect_to case_management_clients_path, notice: success_message
    end

    private

    def tax_return_params
      params.require(:tax_return).permit(:assigned_user_id)
    end
  end
end