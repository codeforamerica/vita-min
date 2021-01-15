class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_groups = user.accessible_vita_partners

    if user.role_type == AdminRole::TYPE
      can :manage, :all
    elsif user.role_type == SiteCoordinatorRole::TYPE || user.role_type == TeamMemberRole::TYPE
      can :manage, User, id: user.id
      can :manage, Client, vita_partner: accessible_groups
    elsif user.role_type == CoalitionLeadRole::TYPE
      can :manage, User, id: user.id
      can :manage, User, role: { coalition_id: user.role.coalition.id }
      can :manage, Client, vita_partner: accessible_groups
    else
      can :manage, User, id: user.id
      can :manage, Client, vita_partner: accessible_groups
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
  end
end
