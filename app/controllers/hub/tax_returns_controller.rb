module Hub
  class TaxReturnsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource
    before_action :load_assignable_users, only: [:edit, :update]
    before_action :load_and_authorize_assignee, only: [:update]

    layout "admin"
    respond_to :js

    def edit; end

    def show; end

    def update
      @tax_return.assign!(assigned_user: @assigned_user, assigned_by: current_user)
      flash.now[:notice] = I18n.t("hub.tax_returns.update.flash_success",
                                  client_name: @tax_return.client.preferred_name,
                                  tax_year: @tax_return.year,
                                  assignee_name: @tax_return.assigned_user ? @tax_return.assigned_user.name : I18n.t("hub.tax_returns.update.no_one"))
      render :show
    end

    private

    def load_assignable_users
      @client = @tax_return.client
      @assignable_users = [current_user, @tax_return.assigned_user].compact
      if @client.vita_partner.present?
        if @client.vita_partner.site?
          team_members = User.where(role: TeamMemberRole.where(site: @client.vita_partner))
          site_coordinators = User.where(role: SiteCoordinatorRole.where(site: @client.vita_partner))
          @assignable_users += team_members.or(site_coordinators).active.order(name: :asc)
        else # client.vita_partner is an organization
          org_leads = User.where(role: OrganizationLeadRole.where(organization: @client.vita_partner))
          @assignable_users += org_leads.active.order(name: :asc)
        end
      end
    end

    def assign_params
      params.permit(:assigned_user_id)
    end

    def load_and_authorize_assignee
      return if assign_params[:assigned_user_id].blank?
      @assigned_user = User.where(id: @assignable_users).find_by(id: assign_params[:assigned_user_id])

      raise CanCan::AccessDenied unless @assigned_user.present?
    end
  end
end
