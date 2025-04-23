module BulkAction
  class SendBulkSignupMessageJob < ApplicationJob
    def perform(bulk_signup_message)
      signup_model = bulk_signup_message.signup_selection.signup_type == "GYR" ? Signup : CtcSignup

      ActiveRecord::Base.transaction do
        signup_model.where(id: bulk_signup_message.signup_selection.id_array).find_each(batch_size: 100) do |signup|
          BulkAction::SendOneBulkSignupMessageJob.perform_later(signup, bulk_signup_message)
        end
      end
    end

    def priority
      PRIORITY_LOW
    end
  end
end
