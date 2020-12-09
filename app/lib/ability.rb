class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_organizations = user.accessible_organizations

    if user.is_admin?
      can :manage, :all
    elsif user.is_client_support?
      can :read, [Client]
    else
      can :manage, [VitaPartner], id: accessible_organizations.pluck(:id)
      can :manage, [Client, User], vita_partner: accessible_organizations
      can :manage, [
        IncomingTextMessage,
        OutgoingTextMessage,
        IncomingEmail,
        OutgoingEmail,
        Note,
        Document,
        TaxReturn,
        SystemNote
      ], client: { vita_partner: accessible_organizations }
    end
  end
end
