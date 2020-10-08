class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, [
      IncomingTextMessage,
      OutgoingTextMessage,
      OutgoingEmail,
      IncomingEmail,
      Client,
      Document,
      Note,
      User
    ] if user.is_beta_tester?
  end
end