module Hub
  class OrganizationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :vita_partner, parent: false

    layout "admin"

    def new
      @coalitions = Coalition.all
      @organization = @vita_partner
    end

    def create
      if @vita_partner.save
        redirect_to hub_organizations_path
      else
        @coalitions = Coalition.all
        render :new
      end
    end

    def show
      raise ActionController::RoutingError.new('Not Found') unless @vita_partner.organization?

      @organization = @vita_partner
      @sites = @organization.child_sites
    end

    def index
      # Load organizations slowly first, to avoid lots of queries later
      organizations = @vita_partners.organizations.includes(:coalition, :child_sites, :organization_capacity).load

      @organizations_by_coalition = if can? :read, Coalition
                                      organizations.group_by(&:coalition).sort_by { |el| [el[0]&.name ? 0 : 1, el[0]&.name || 0] } # sort independent org (nil coalition) to end of list
                                    else
                                      { nil => organizations }
                                    end
    end

    def edit
      @coalitions = Coalition.all
      @routing_form = ZipCodeRoutingForm.new(@vita_partner)
      @source_params_form = SourceParamsForm.new(@vita_partner)
      @organization = @vita_partner
    end

    def update
      if @vita_partner.update(vita_partner_params)
        flash[:notice] = I18n.t("general.changes_saved")
        redirect_to edit_hub_organization_path(id: @vita_partner.id)
      else
        @coalitions = Coalition.all
        @organization = @vita_partner
        flash.now[:alert] = I18n.t("general.error.form_failed")
        render :edit
      end
    end

    def suspend_all
      users_to_suspend = []
      case suspend_all_role_param
      when OrganizationLeadRole::TYPE
        users_to_suspend = @vita_partner.organization_leads
      when SiteCoordinatorRole::TYPE
        users_to_suspend = @vita_partner.site_coordinators
      when TeamMemberRole::TYPE
        users_to_suspend = @vita_partner.team_members
      end
      users_to_suspend_count = users_to_suspend.active.count
      users_to_suspend.active.each(&:suspend!)

      flash[:alert] = I18n.t("hub.organizations.suspended_all.success", count: users_to_suspend_count)
      redirect_to edit_hub_organization_path(id: @vita_partner.id)
    end

    def activate_all
      users_to_activate = []
      case activate_all_role_param
      when OrganizationLeadRole::TYPE
        users_to_activate = @vita_partner.organization_leads
      when SiteCoordinatorRole::TYPE
        users_to_activate = @vita_partner.site_coordinators
      when TeamMemberRole::TYPE
        users_to_activate = @vita_partner.team_members
      end
      users_to_activate_count = users_to_activate.suspended.count
      users_to_activate.suspended.each(&:activate!)

      flash[:alert] = I18n.t("hub.organizations.activated_all.success", count: users_to_activate_count)
      redirect_to edit_hub_organization_path(id: @vita_partner.id)
    end

    private

    def suspend_all_role_param
      params.require(:role_type)
    end

    def activate_all_role_param
      params.require(:role_type)
    end

    def vita_partner_params
      params.require(:vita_partner).permit(:name, :coalition_id, :timezone, :capacity_limit, :allows_greeters, source_parameters_attributes: [:_destroy, :id, :code])
    end
  end
end
