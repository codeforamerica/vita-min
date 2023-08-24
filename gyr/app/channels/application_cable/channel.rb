module ApplicationCable
  class Channel < ActionCable::Channel::Base
    delegate :current_user, to: :connection

    def current_ability
      @ability ||= Ability.new(current_user)
    end
  end
end
