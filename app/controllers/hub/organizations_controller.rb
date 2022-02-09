module Hub
  class OrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in

    before_action :load_coalitions
    load_and_authorize_resource

    layout "hub"

    def index
      @presenter = Hub::OrganizationsPresenter.new(current_ability)
    end

    def show
      raise ActionController::RoutingError.new('Not Found') unless @organization.organization?

      @sites = @organization.child_sites
    end

    def new
      @organization_form = OrganizationForm.new(Organization.new, {})
    end

    def edit
      @routing_form = ZipCodeRoutingForm.new(@organization)
      @source_params_form = SourceParamsForm.new(@organization)
      @organization_form = OrganizationForm.from_record(@organization)
    end

    def create
      @organization_form = OrganizationForm.new(@organization, organization_form_params)
      if @organization_form.save
        redirect_to hub_organizations_path
      else
        render :new
      end
    end

    def update
      @organization_form = OrganizationForm.new(@organization, organization_form_params)
      if @organization_form.save
        flash[:notice] = I18n.t("general.changes_saved")
        redirect_to edit_hub_organization_path(id: @organization.id)
      else
        flash.now[:alert] = I18n.t("general.error.form_failed")
        render :edit
      end
    end

    def suspend_all
      users_to_suspend = []
      case suspend_all_role_param
      when OrganizationLeadRole::TYPE
        users_to_suspend = @organization.organization_leads
      when SiteCoordinatorRole::TYPE
        users_to_suspend = @organization.site_coordinators
      when TeamMemberRole::TYPE
        users_to_suspend = @organization.team_members
      end
      users_to_suspend_count = users_to_suspend.active.count
      users_to_suspend.active.each(&:suspend!)

      flash[:alert] = I18n.t("hub.organizations.suspended_all.success", count: users_to_suspend_count)
      redirect_to edit_hub_organization_path(id: @organization.id)
    end

    def activate_all
      users_to_activate = []
      case activate_all_role_param
      when OrganizationLeadRole::TYPE
        users_to_activate = @organization.organization_leads
      when SiteCoordinatorRole::TYPE
        users_to_activate = @organization.site_coordinators
      when TeamMemberRole::TYPE
        users_to_activate = @organization.team_members
      end
      users_to_activate_count = users_to_activate.suspended.count
      users_to_activate.suspended.each(&:activate!)

      flash[:alert] = I18n.t("hub.organizations.activated_all.success", count: users_to_activate_count)
      redirect_to edit_hub_organization_path(id: @organization.id)
    end

    private

    def suspend_all_role_param
      params.require(:role_type)
    end

    def activate_all_role_param
      params.require(:role_type)
    end

    def organization_form_params
      params.require(:hub_organization_form).permit(
        :name, :is_independent, :states, :coalition_id, :timezone, :accepts_itin_applicants, :capacity_limit, :allows_greeters, source_parameters_attributes: [:_destroy, :id, :code]
      )
    end

    def load_coalitions
      @coalitions = Coalition.all
    end
  end
end
