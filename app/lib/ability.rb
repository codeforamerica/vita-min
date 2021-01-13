class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_organizations = user.accessible_organizations

    if user.role_type == AdminRole::TYPE
      can :manage, :all
    elsif user.role_type == SiteCoordinatorRole::TYPE
      can :manage, User, id: user.id
      can :manage, Client, vita_partner: accessible_organizations
    elsif user.role_type == TeamMemberRole::TYPE
      can :manage, User, id: user.id
      can :read, Client, vita_partner: accessible_organizations
    else
      can :manage, User, id: user.id
      can :manage, Client, vita_partner: accessible_organizations
      can :manage, [
        IncomingTextMessage,
        OutgoingTextMessage,
        IncomingEmail,
        OutgoingEmail,
        Note,
        Document,
        TaxReturn,
        SystemNote,
      ], client: { vita_partner: accessible_organizations }
    end
  end
end
