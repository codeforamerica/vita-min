class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_groups = user.accessible_vita_partners

    # If role is nil, no permissions
    if user.role_type.nil? || user.role_id.nil?
      return
    end

    # Admins can do everything
    if user.role_type == AdminRole::TYPE
      can :manage, :all
      return
    end

    # Anyone can manage their name & email address (roles are handled separately)
    can :manage, User, id: user.id
    # Anyone can manage clients in the groups they can access
    can :manage, Client, vita_partner: accessible_groups
    # Anyone can read info about an organization or site they can access
    can :read, VitaPartner, id: accessible_groups.pluck(:id)

    # With cancancan, the easiest way to write controllers that do access control is if the
    # model for that controller has permissions assigned to it.
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

    # Limit the types of new users one can create:

    # Coalition leads can create coalition leads, organization leads, site coordinators, and team members in their coalition
    if user.role_type == CoalitionLeadRole::TYPE
      can :manage, CoalitionLeadRole, coalition: user.role.coalition
      can :manage, OrganizationLeadRole, organization: { coalition_id: user.role.coalition_id }
      can :manage, SiteCoordinatorRole, site: { parent_organization: { coalition: user.role.coalition } }
      can :manage, TeamMemberRole, site: { parent_organization: { coalition: user.role.coalition } }
    end

    # Organization leads can create organization leads, site coordinators, and team members in their org
    if user.role_type == OrganizationLeadRole::TYPE
      can :manage, OrganizationLeadRole, organization: user.role.organization
      can :manage, SiteCoordinatorRole, site: { parent_organization: user.role.organization }
      can :manage, TeamMemberRole, site: { parent_organization: user.role.organization }
    end

    # Site coordinators can create site coordinators and team members in their site
    if user.role_type == SiteCoordinatorRole::TYPE
      can :manage, SiteCoordinatorRole, site: user.role.site
      can :manage, TeamMemberRole, site: user.role.site
    end
  end
end
