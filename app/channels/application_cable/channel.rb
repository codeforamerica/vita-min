module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def current_ability
      @ability ||= Ability.new(current_user)
    end
  end
end
