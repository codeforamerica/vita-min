module ChannelHelpers
  extend ActiveSupport::Concern

  def connect_as(user)
    stub_connection current_user: user
  end
end