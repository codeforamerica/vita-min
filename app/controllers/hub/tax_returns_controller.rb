module Hub
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
      no_one = I18n.t("hub.tax_returns.update.no_one")
      success_message = I18n.t(
        "hub.tax_returns.update.flash_success",
        assignee_name: @tax_return.assigned_user.present? ? @tax_return.assigned_user.name : no_one,
        client_name: @client.preferred_name,
        tax_year: @tax_return.year,
      )
      SystemNote.create_assignment_change_note(current_user, @tax_return)
      redirect_to hub_clients_path, notice: success_message
    end

    private

    def set_assignable_users
      @assignable_users = @client.vita_partner.users
    end

    def assign_params
      params.require(:tax_return).permit(:assigned_user_id)
    end
  end
end
