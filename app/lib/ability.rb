class Ability
  include CanCan::Ability

  def initialize(user)
    # If user or role is nil, no permissions
    if user.nil? || user.role_type.nil? || user.role_id.nil?
      return
    end

    # Custom client controller actions
    alias_action :flag, :toggle_field,
                 :edit_take_action, :update_take_action,
                 :edit_13614c_form_page1, :edit_13614c_form_page2,
                 :edit_13614c_form_page3, :edit_13614c_form_page4, :edit_13614c_form_page5,
                 :update_13614c_form_page1, :update_13614c_form_page2,
                 :update_13614c_form_page3, :update_13614c_form_page4, :update_13614c_form_page5,
                 :cancel_13614c, :save_and_maybe_exit,
                 to: :hub_client_management

    accessible_groups = user.accessible_vita_partners

    # Admins can do everything
    if user.admin?
      # All admins who are also state file
      can :manage, :all

      # Non-NJ staff cannot manage NJ EfileErrors, EfileSubmissions or FAQs
      cannot :manage, EfileError, service_type: "state_file_nj"
      cannot :manage, EfileSubmission, data_source_type: "StateFileNjIntake"
      cannot :manage, FaqCategory, product_type: "state_file_nj"
      cannot :manage, FaqItem, faq_category: { product_type: "state_file_nj" }

      unless user.state_file_admin?
        StateFile::StateInformationService.state_intake_classes.each do |intake_class|
          cannot :manage, intake_class
        end
        # Enumerate classes here...
        cannot :manage, StateFile::AutomatedMessage
        cannot :manage, StateFile1099G
        cannot :manage, StateFileDependent
        cannot :manage, StateFileW2
        cannot :manage, StateId
        cannot :manage, EfileSubmission, data_source_type: StateFile::StateInformationService.state_intake_class_names
        cannot :manage, EfileError do |error|
          %w[state_file unfilled state_file_az state_file_ny state_file_md state_file_nc state_file_id].include?(error.service_type)
        end
      end
      unless user.email.downcase.include?("@codeforamerica.org")
        cannot :manage, :flipper_dashboard
      end
      return
    end

    if user.client_success?
      # Allow client success to manage basically everything in regards to clients
      can :manage, :all
      # Remove some user and organization management capabilities
      cannot :manage, Organization
      cannot :manage, CoalitionLeadRole
      cannot :manage, OrganizationLeadRole
      cannot :manage, TeamMemberRole
      cannot :manage, AdminRole
      cannot :manage, StateFileNjStaffRole
      cannot :manage, ClientSuccessRole
      cannot :manage, SiteCoordinatorRole
      cannot :manage, GreeterRole
      # Does not return, so other rules may be further scoped to accessible_groups
    end

    # Anyone can manage their name & email address (roles are handled separately)
    can :manage, User, id: user.id

    # Anyone can read info about users that they can access
    can :read, User, id: user.accessible_users.ids

    # Anyone can read info about an organization or site they can access
    can :read, Organization, id: accessible_groups.pluck(:id)
    can :read, Site, id: accessible_groups.pluck(:id)

    # HUB CLIENT CONTROLLER PERMISSIONS
    # overly permissive, need to narrow permissions
    # break out role and specify permissions when making modifications
    client_role_whitelist = [
      :client_success, :admin, :org_lead, :site_coordinator,
      :coalition_lead, :state_file_admin, :team_member
    ].freeze

    if user.role?(client_role_whitelist)
      can :read, Client, vita_partner: accessible_groups

      can [:create, :update, :hub_client_management],
          Client, vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year }
    end

    if user.role?([:admin, :org_lead, :site_coordinator])
      can :unlock, Client, vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year }
    end

    if user.greeter?
      general_states = %w[intake_ready intake_greeter_info_requested intake_needs_doc_help]
      assigned_states = %w[file_not_filing file_hold]

      can :read, Client, tax_returns: { current_state: general_states }, vita_partner: accessible_groups
      can :read, Client, tax_returns: { current_state: assigned_states, assigned_user: user }, vita_partner: accessible_groups

      can [:update, :hub_client_management], Client,
          tax_returns: { current_state: general_states },
          vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year }

      can [:update, :hub_client_management], Client,
          tax_returns: { current_state: assigned_states, assigned_user: user },
          vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year }
    end

    # Only admins can destroy clients
    cannot :destroy, Client unless user.admin?

    can [:read], [
      Note,
      Document,
      TaxReturn
    ], client: { vita_partner: accessible_groups }

    can [:create, :update, :destroy], [
      Note,
      TaxReturn
    ], client: { vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year } }

    can [:create, :update, :destroy, :archived, :confirm],
        Document, client: { vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year } }

    can :manage, [
      IncomingEmail,
      IncomingTextMessage,
      OutgoingEmail,
      OutgoingTextMessage,
      SystemNote,
    ], client: { vita_partner: accessible_groups }

    can :manage, TaxReturnSelection, tax_returns: { client: { vita_partner: accessible_groups, intake: { product_year: Rails.configuration.product_year } } }

    can :manage, EfileSubmission, tax_return: { client: { vita_partner: accessible_groups } }

    cannot :index, EfileSubmission unless user.admin? || user.client_success?
    StateFile::StateInformationService.state_intake_classes.each do |intake_class|
      cannot :manage, intake_class
    end
    cannot :manage, StateFile1099G
    cannot :manage, StateFileDependent
    cannot :manage, StateFileW2
    cannot :manage, StateId

    if user.state_file_nj_staff?
      can :manage, :state_file_admin_tool
      can :read, StateFile::AutomatedMessage

      can :manage, EfileError, service_type: "state_file_nj"
      can :manage, EfileSubmission, data_source_type: "StateFileNjIntake"
      can :manage, FaqCategory, product_type: "state_file_nj"
      can :manage, FaqItem, faq_category: { product_type: "state_file_nj" }
    end

    if user.coalition_lead?
      can :read, Coalition, id: user.role.coalition_id

      # Coalition leads can view and edit users who are coalition leads, organization leads, site coordinators, and team members in their coalition
      can :manage, User, id: user.accessible_users.ids

      # Coalition leads can create coalition leads, organization leads, site coordinators, and team members in their coalition
      can :manage, CoalitionLeadRole, coalition: user.role.coalition
      can :manage, OrganizationLeadRole, organization: { coalition_id: user.role.coalition_id }
      can :manage, SiteCoordinatorRole, sites: { parent_organization: { coalition: user.role.coalition } }
      can :manage, TeamMemberRole, sites: { parent_organization: { coalition: user.role.coalition } }
    end

    if user.org_lead?

      # Organization leads can view and edit users who are organization leads, site coordinators, and team members in their coalition
      can :manage, User, id: user.accessible_users.ids

      # Organization leads can create organization leads, site coordinators, and team members in their org
      can :manage, OrganizationLeadRole, organization: user.role.organization
      can :manage, SiteCoordinatorRole, sites: { parent_organization: user.role.organization }
      can :manage, TeamMemberRole, sites: { parent_organization: user.role.organization }
    end

    if user.site_coordinator?
      # Site coordinators can create site coordinators and team members in their site
      can :manage, SiteCoordinatorRole do |role|
        user.role.sites.map.any? { |site| role.sites.map(&:id).include? site.id }
      end
      can :manage, TeamMemberRole do |role|
        user.role.sites.map.any? { |site| role.sites.map(&:id).include? site.id }
      end
    end
  end
end
