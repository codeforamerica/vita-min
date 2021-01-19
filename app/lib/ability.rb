class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_groups = user.accessible_vita_partners

    if user.role_type == AdminRole::TYPE
      can :manage, :all
    elsif user.role_type == SiteCoordinatorRole::TYPE || user.role_type == TeamMemberRole::TYPE || user.role_type == CoalitionLeadRole::TYPE
      can :manage, User, id: user.id
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

    if user.role_type == CoalitionLeadRole::TYPE
      can :read, Coalition, id: user.role.coalition.id
      can :read, VitaPartner, id: accessible_groups.pluck(:id)
    end
  end
end
