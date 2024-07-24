class Ability
  include CanCan::Ability

  def initialize(user)
    # If user or role is nil, no permissions
    if user.nil? || user.role_type.nil? || user.role_id.nil?
      return
    end

    accessible_groups = user.accessible_vita_partners

    # Admins can do everything
    if user.admin?
      # All admins who are also state file
      can :manage, :all
      unless user.state_file_admin?
        StateFile::StateInformationService.state_intake_classes.each do |intake_class|
          cannot :manage, intake_class
        end
        # Enumerate classes here...
        cannot :manage, StateFile1099G
        cannot :manage, StateFileDependent
        cannot :manage, StateFileW2
        cannot :manage, StateId
        cannot :manage, EfileSubmission, id: EfileSubmission.for_state_filing.pluck(:id)
        cannot :manage, EfileError do |error|
          error.service_type == "state_file" || error.service_type == "unfilled"
        end
      end
      unless user.email.include?("@codeforamerica.org")
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
      cannot :manage, ClientSuccessRole
      cannot :manage, SiteCoordinatorRole
      cannot :manage, GreeterRole
      # Does not return, so other rules may be further scoped to accessible_groups
    end

    # Anyone can manage their name & email address (roles are handled separately)
    can :manage, User, id: user.id

    # Anyone can read info about users that they can access
    can :read, User, id: user.accessible_users.pluck(:id)

    # Anyone can read info about an organization or site they can access
    can :read, Organization, id: accessible_groups.pluck(:id)
    can :read, Site, id: accessible_groups.pluck(:id)

    # This was overly permissive. We should work out what the permissions should
    # be for each role and reduce this check. As we need to modify this, please
    # break out the role and specify permissions more granularly
    client_role_whitelist = [
      :client_success, :admin, :org_lead, :site_coordinator,
      :coalition_lead, :state_file_admin, :team_member
    ].freeze

    if user.role?(client_role_whitelist)
      can :manage, Client, vita_partner: accessible_groups
    end

    if user.greeter?
      # NOTE: that because of the complexity of the look up, we have to define it
      # twice. Once in the block for individual items and once in call for scope
      # look ups

      json_params = [
        [{current_state: "intake_ready"}],
        [{current_state: "intake_greeter_info_requested"}],
        [{current_state: "intake_need_doc_help"}],
        [{current_state: "file_not_filing"}]
      ]

      json_query = Array.new(json_params.count, "filterable_tax_return_properties @> ?::jsonb").join(" OR ")

      can [:edit, :read],
        Client,
        # Funky, I know, but it allows composition of abilities. Still, could be
        # a regular where if that's not important
        ["vita_partner_id IN (?) AND #{json_query}", accessible_groups.pluck(:id), *json_params.map(&:to_json)] do |client|

        # Results in something like ["intake_ready",
        # "intake_greeter_info_requested"]. Duplicates possible. Doing it this
        # way allows us to specify the params a single time and use them in both
        # places
        query_values = json_params.flat_map { |value| value[0][:current_state] }
        state_values = client.filterable_tax_return_properties.map { |props| props['current_state'] }

        # If both in the accessible groups and we detect an overlap between
        # query values and state values, we're good.
        [
          accessible_groups.include?(client.vita_partner),
          (query_values & state_values).present?
        ].all?
      end
    end

    # Only admins can destroy clients
    cannot :destroy, Client unless user.admin?
    can :manage, [
      Document,
      IncomingEmail,
      IncomingTextMessage,
      Note,
      OutgoingEmail,
      OutgoingTextMessage,
      SystemNote,
      TaxReturn,
    ], client: { vita_partner: accessible_groups }

    can :manage, TaxReturnSelection, tax_returns: { client: { vita_partner: accessible_groups } }
    cannot :manage, TaxReturnSelection, tax_returns: { client: { vita_partner: VitaPartner.where.not(id: accessible_groups) }}

    can :manage, EfileSubmission, tax_return: { client: { vita_partner: accessible_groups } }

    cannot :index, EfileSubmission unless user.admin? || user.client_success?
    StateFile::StateInformationService.state_intake_classes.each do |intake_class|
      cannot :manage, intake_class
    end
    cannot :manage, StateFile1099G
    cannot :manage, StateFileDependent
    cannot :manage, StateFileW2
    cannot :manage, StateId

    if user.role_type == CoalitionLeadRole::TYPE
      can :read, Coalition, id: user.role.coalition_id

      # Coalition leads can view and edit users who are coalition leads, organization leads, site coordinators, and team members in their coalition
      can :manage, User, id: user.accessible_users.pluck(:id)

      # Coalition leads can create coalition leads, organization leads, site coordinators, and team members in their coalition
      can :manage, CoalitionLeadRole, coalition: user.role.coalition
      can :manage, OrganizationLeadRole, organization: { coalition_id: user.role.coalition_id }
      can :manage, SiteCoordinatorRole, sites: { parent_organization: { coalition: user.role.coalition } }
      can :manage, TeamMemberRole, sites: { parent_organization: { coalition: user.role.coalition } }
    end

    if user.role_type == OrganizationLeadRole::TYPE

      # Organization leads can view and edit users who are organization leads, site coordinators, and team members in their coalition
      can :manage, User, id: user.accessible_users.pluck(:id)

      # Organization leads can create organization leads, site coordinators, and team members in their org
      can :manage, OrganizationLeadRole, organization: user.role.organization
      can :manage, SiteCoordinatorRole, sites: { parent_organization: user.role.organization }
      can :manage, TeamMemberRole, sites: { parent_organization: user.role.organization }
    end

    if user.role_type == SiteCoordinatorRole::TYPE
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
