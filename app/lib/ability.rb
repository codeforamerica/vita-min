class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_groups = user.accessible_vita_partners

    if user.role_type == AdminRole::TYPE
      can :manage, :all
    elsif user.role_type == SiteCoordinatorRole::TYPE || user.role_type == TeamMemberRole::TYPE || user.role_type == CoalitionLeadRole::TYPE
      can :manage, User, id: user.id
      can :read, VitaPartner, id: accessible_groups.pluck(:id)
      can :manage, Client, vita_partner: accessible_groups
    else
      can :manage, User, id: user.id
      can :manage, Client, vita_partner: accessible_groups
      can :read, VitaPartner, id: accessible_groups.pluck(:id)
      can :manage, [
        IncomingTextMessage,
        OutgoingTextMessage,
        IncomingEmail,
        OutgoingEmail,
        Note,
        Document,
        TaxReturn,
        SystemNote,
      ], client: { vita_partner: accessible_groups }
    end

    if user.role_type == CoalitionLeadRole::TYPE
      can :manage, CoalitionLeadRole, coalition: user.role.coalition
      can :manage, OrganizationLeadRole, organization: { coalition_id: user.role.coalition_id }
      can :manage, SiteCoordinatorRole, site: { parent_organization: { coalition: user.role.coalition } }
      can :manage, TeamMemberRole, site: { parent_organization: { coalition: user.role.coalition } }
    end

    if user.role_type == OrganizationLeadRole::TYPE
      can :manage, OrganizationLeadRole, organization: user.role.organization
      can :manage, SiteCoordinatorRole, site: { parent_organization: user.role.organization }
      can :manage, TeamMemberRole, site: { parent_organization: user.role.organization }
    end

    if user.role_type == SiteCoordinatorRole::TYPE
      can :manage, SiteCoordinatorRole, site: user.role.site
      can :manage, TeamMemberRole, site: user.role.site
    end
  end
end
