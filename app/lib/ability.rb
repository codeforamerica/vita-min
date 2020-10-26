class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_admin && user.is_beta_tester
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

    if user.is_beta_tester
      can :manage, [Client, User], vita_partner_id: user.vita_partner_id
      can :manage, [
          IncomingTextMessage,
          OutgoingTextMessage,
          IncomingEmail,
          OutgoingEmail,
          Document,
          Note,
          TaxReturn,
      ], client: {vita_partner_id: user.vita_partner_id}
    end
  end
end