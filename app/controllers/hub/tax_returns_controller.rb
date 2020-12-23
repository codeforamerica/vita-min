module Hub
  class TaxReturnsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource
    before_action :set_assignable_users, only: [:edit]

    layout "admin"
    respond_to :js

    def edit; end

    def show; end

    def update
      @tax_return.update!(assign_params)
      SystemNote.create_assignment_change_note(current_user, @tax_return)
      flash.now[:notice] = I18n.t("hub.tax_returns.update.flash_success",
                                  client_name: @tax_return.client.preferred_name,
                                  tax_year: @tax_return.year,
                                  assignee_name: @tax_return.assigned_user ? @tax_return.assigned_user.name : I18n.t("hub.tax_returns.update.no_one"))
      render :show
    end

    private

    def set_assignable_users
      @assignable_users = User.preload(:role).joins(:organization_lead_role).where("organization_lead_roles.vita_partner_id = ?", @tax_return.client.vita_partner_id).to_a
      @assignable_users.push(@tax_return.assigned_user) if @tax_return.assigned_user # make sure the assigned user displays in the list
      @assignable_users.push(current_user) unless @assignable_users.include?(current_user)
    end

    def assign_params
      params.permit(:assigned_user_id)
    end
  end
end
