module BulkAction
  class SendBulkSignupMessageJob < ApplicationJob
    def perform(bulk_signup_message)
      ActiveRecord::Base.transaction do
        Signup.where(id: bulk_signup_message.signup_selection.id_array).find_each do |signup|
          BulkAction::SendOneBulkSignupMessageJob.perform_later(signup, bulk_signup_message)
        end
      end
    end
  end
end
