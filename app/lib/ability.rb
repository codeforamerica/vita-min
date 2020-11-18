class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?
    accessible_organizations = user.accessible_organizations

    if user.is_admin?
      can :manage, :all
    else
      can :manage, [VitaPartner], id: accessible_organizations.pluck(:id)
      can :manage, Client, vita_partner: accessible_organizations
      can :manage, User, memberships: { vita_partner: accessible_organizations }
      cannot :edit_organization, Client do |client|
        !user.can_lead?(client.vita_partner) || accessible_organizations.length == 1
      end
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
