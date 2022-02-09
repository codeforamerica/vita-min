class Ability
  include CanCan::Ability

  def initialize(user)
    # If user or role is nil, no permissions
    if user.nil? || user.role_type.nil? || user.role_id.nil?
      return
    end

    accessible_groups = user.accessible_vita_partners

    # Admins can do everything
    if user.role_type == AdminRole::TYPE
      can :manage, :all
      return
    end

    # Anyone can manage their name & email address (roles are handled separately)
    can :manage, User, id: user.id

    # Anyone can read info about users that they can access
    can :read, User, id: user.accessible_users.pluck(:id)

    # Anyone can read info about an organization or site they can access
    can :read, Organization, id: accessible_groups.pluck(:id)
    can :read, Site, id: accessible_groups.pluck(:id)

    # Anyone can manage clients and client data in the groups they can access
    can :manage, Client, vita_partner: accessible_groups
    # Only admins can destroy clients
    cannot :destroy, Client unless user.role_type == AdminRole::TYPE
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

    can :manage, EfileSubmission, tax_return: { client: { vita_partner: accessible_groups } }

    cannot :index, EfileSubmission unless user.role_type == AdminRole::TYPE

    if user.role_type == CoalitionLeadRole::TYPE
      can :read, Coalition, id: user.role.coalition_id

      # Coalition leads can view and edit users who are coalition leads, organization leads, site coordinators, and team members in their coalition
      can :manage, User, id: user.accessible_users.pluck(:id)

      # Coalition leads can create coalition leads, organization leads, site coordinators, and team members in their coalition
      can :manage, CoalitionLeadRole, coalition: user.role.coalition
      can :manage, OrganizationLeadRole, organization: { coalition_id: user.role.coalition_id }
      can :manage, SiteCoordinatorRole, site: { parent_organization: { coalition: user.role.coalition } }
      can :manage, TeamMemberRole, site: { parent_organization: { coalition: user.role.coalition } }
    end

    if user.role_type == OrganizationLeadRole::TYPE

      # Organization leads can view and edit users who are organization leads, site coordinators, and team members in their coalition
      can :manage, User, id: user.accessible_users.pluck(:id)

      # Organization leads can create organization leads, site coordinators, and team members in their org
      can :manage, OrganizationLeadRole, organization: user.role.organization
      can :manage, SiteCoordinatorRole, site: { parent_organization: user.role.organization }
      can :manage, TeamMemberRole, site: { parent_organization: user.role.organization }
    end

    if user.role_type == SiteCoordinatorRole::TYPE
      # Site coordinators can create site coordinators and team members in their site
      can :manage, SiteCoordinatorRole, site: user.role.site
      can :manage, TeamMemberRole, site: user.role.site
    end
  end
end
