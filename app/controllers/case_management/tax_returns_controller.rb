module CaseManagement
  class TaxReturnsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    before_action :set_assignable_users, only: [:edit]

    layout "admin"

    def edit; end

    def update
      @tax_return.update!(assign_params)
      no_one = I18n.t("case_management.tax_returns.update.no_one")
      success_message = I18n.t(
        "case_management.tax_returns.update.flash_success",
        assignee_name: @tax_return.assigned_user.present? ? @tax_return.assigned_user.name : no_one,
        client_name: @client.preferred_name,
        tax_year: @tax_return.year,
      )
      redirect_to case_management_clients_path, notice: success_message
    end

    def edit_status; end

    def update_status
      if @tax_return.update(status_params)
        redirect_to case_management_client_messages_path(client_id: @client.id)
      end
    end

    private

    def set_assignable_users
      @assignable_users = @client.vita_partner.users
    end

    def assign_params
      params.require(:tax_return).permit(:assigned_user_id)
    end

    def status_params
      params.require(:tax_return).permit(:status)
    end
  end
end