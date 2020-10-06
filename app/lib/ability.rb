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
      User
    ] if user.is_beta_tester?
  end
end