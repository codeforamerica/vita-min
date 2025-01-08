module StateFile
  module ArchivedIntakes
    class IdentificationNumberForm < Form
      validates :ssn, social_security_number: true, presence: true

      def initialize(attributes = {})
        super
        assign_attributes(attributes)
      end

      def validates_ssn_associated_with_archived_intake
        # validates if SSN is nine digits, blah blah
        # if it's not valid AND we have a previous login attempt, we'd just throw an error


        attempts = StateFileArchivedIntakeAccessLog.where(
          ip_address: ip_for_irs,
          event_type: 5,
          created_at: Time.now - 5 # less than 1 hour
        ).count
        if attempts >= 2
          errors.add(:ssn, "You have 1 attempt left")
        else
          errors.add(:no_remaining_attempts, true)
        end
      end

      # lock out the email if two attempts are made on that email
      # lock out the ssn if two attempts are made

      # how many different emails from the same IP address?

      # 1. would it be alright if we passed the email address by session?

      def save
        run_callbacks :save do
          valid?
        end
      end
    end
  end
end
