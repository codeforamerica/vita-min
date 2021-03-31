module Hub
  class TaxReturnsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    authorize_resource :client, parent: false, only: [:new, :create]
    load_and_authorize_resource except: [:new, :create]
    load_resource through: @client, only: [:new, :create]
    before_action :prepare_form, only: [:new]
    before_action :load_assignable_users, except: [:show]
    before_action :load_and_authorize_assignee, only: [:update]

    layout "admin"
    respond_to :js, except: [:new, :create]

    def new
      if @remaining_years.blank?
        flash[:notice] = "There are no remaining tax years to create a return for."
        redirect_to hub_client_path(id: @client.id)
      end
    end

    def create
      if @tax_return.valid?
        @tax_return.save!
        SystemNote::TaxReturnCreated.generate!(initiated_by: current_user, tax_return: @tax_return)
        flash[:notice] = I18n.t("hub.tax_returns.create.success", year: @tax_return.year, name: @client.preferred_name)
        redirect_to hub_client_path(id: @client.id)
      else
        prepare_form
        flash[:notice] = I18n.t("forms.errors.general")
        render :new
      end
    end

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
      @client ||= @tax_return.client
      @tax_return ||= TaxReturn.new
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
      @assignable_users.uniq!
    end

    def assign_params
      params.permit(:assigned_user_id)
    end

    def tax_return_params
      params.require(:tax_return).permit(:year, :assigned_user_id, :certification_level, :status).merge(client_id: params[:client_id])
    end

    def prepare_form
      @client = Client.find_by(id: params[:client_id])
      @tax_return_years = @client.tax_returns.pluck(:year)
      @remaining_years = TaxReturn.filing_years - @tax_return_years
    end

    def load_and_authorize_assignee
      return if assign_params[:assigned_user_id].blank?

      @assigned_user = User.where(id: @assignable_users).find_by(id: assign_params[:assigned_user_id])

      raise CanCan::AccessDenied unless @assigned_user.present?
    end
  end
end
