class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_organizations = user.accessible_organizations
    alias_action :create, :read, :update, :destroy, to: :administer

    if user.is_admin?
      can :administer, :all
    else
      can :administer, [VitaPartner], id: accessible_organizations.pluck(:id)
      can :administer, [Client, User], vita_partner: accessible_organizations
      can :administer, [
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
