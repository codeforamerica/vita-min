module BulkAction
  class SendBulkSignupMessageJob < ApplicationJob
    def perform(bulk_signup_message)
      bulk_signup_message.signup_selection.id_array.each do |signup_id|
        BulkAction::SendOneBulkSignupMessageJob.perform_later(Signup.find(signup_id), bulk_signup_message)
      end
    end
  end
end
