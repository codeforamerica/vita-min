class SendSignupMessageJob < ApplicationJob
  def self.perform(message_name, batch_size=nil)
    Signup.send_message(message_name, batch_size)
  end
end