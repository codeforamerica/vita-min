class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    accessible_organizations = user.accessible_organizations
    alias_action :response_needed, :update_take_action, :edit_take_action, to: :update
    alias_action :read, :create, :update, :destroy, to: :crud

    if user.is_admin?
      can :manage, :all
    else
      can :manage, [VitaPartner], id: accessible_organizations.pluck(:id)
      can :manage, User, memberships: { vita_partner: accessible_organizations }

      can :crud, Client, vita_partner: accessible_organizations
      can :edit_organization, Client do |client|
        user.can_lead?(client.vita_partner)
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
