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
        can :manage, [Client, User], vita_partner: user.vita_partner
        can :manage, [
          IncomingTextMessage,
          OutgoingTextMessage,
          IncomingEmail,
          OutgoingEmail,
          Note,
          Document,
          TaxReturn,
        ], client: { vita_partner: user.vita_partner }
        can :manage, [
          Document,
        ], intake: { vita_partner: user.vita_partner }
      end
    end
  end
end