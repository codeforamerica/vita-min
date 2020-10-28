class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_beta_tester
      if user.is_admin
        can :manage, [
            Client,
            User,
            IncomingTextMessage,
            OutgoingTextMessage,
            IncomingEmail,
            OutgoingEmail,
            Document,
            Note,
            TaxReturn
        ]
      end

      if user.vita_partner.present?
        can :manage, [Client, User], vita_partner: [user.vita_partner, *user.supported_organizations]
        can :manage, [
            IncomingTextMessage,
            OutgoingTextMessage,
            IncomingEmail,
            OutgoingEmail,
            Document,
            Note,
            TaxReturn,
        ], client: { vita_partner: [user.vita_partner, *user.supported_organizations] }
      end
    end
  end
end