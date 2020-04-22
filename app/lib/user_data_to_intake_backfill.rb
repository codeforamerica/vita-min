# Backfills new intake columns from existing values on user model. This can be removed
# once it is run once in a production console.
#
# Usage (in rails console):
# > UserDataToIntakeBackfill.run
#

PRIMARY_COLUMN_MAP = {
  primary_consented_to_service: :consented_to_service,
  primary_consented_to_service_at: :consented_to_service_at,
  primary_consented_to_service_ip: :consented_to_service_ip,
  email_notification_opt_in: :email_notification_opt_in,
  sms_notification_opt_in: :sms_notification_opt_in,
  email_address: :email,
  phone_number: :phone_number,
  primary_first_name: :first_name,
  primary_last_name: :last_name,
}

SPOUSE_COLUMN_MAP = {
  spouse_consented_to_service: :consented_to_service,
  spouse_consented_to_service_at: :consented_to_service_at,
  spouse_consented_to_service_ip: :consented_to_service_ip,
  spouse_email_address: :email,
  spouse_first_name: :first_name,
  spouse_last_name: :last_name,
}

class UserDataToIntakeBackfill
  def self.run
    puts "~~~~~~~~~~~~ BEGIN BACKFILL ~~~~~~~~~~~~"

    Intake.all.each do |intake|
      if intake.primary_user.present?
        puts "~~~~~~~~~~~~ UPDATING PRIMARY USER COLUMNS ~~~~~~~~~~~~"

        if intake.primary_birth_date.blank? && intake.primary_user.birth_date.present?
          puts "============ updating primary_birth_date"
          intake.update(primary_birth_date: intake.primary_user.parsed_birth_date)
        end

        if intake.primary_last_four_ssn.blank? && intake.primary_user.ssn.present?
          puts "============ updating encrypted_primary_last_four_ssn"
          intake.update(primary_last_four_ssn: intake.primary_user.ssn_last_four)
        end

        PRIMARY_COLUMN_MAP.each do |intake_column, user_column|
          if intake[intake_column].blank? && intake.primary_user[user_column].present?
            puts "============ updating #{intake_column}"
            intake.update(intake_column => intake.primary_user[user_column])
          end
        end
      end

      if intake.spouse.present?
        puts "~~~~~~~~~~~~ UPDATING SPOUSE USER COLUMNS ~~~~~~~~~~~~"

        if intake.spouse_birth_date.blank? && intake.spouse.birth_date.present?
          puts "============ updating spouse_birth_date"
          intake.update(spouse_birth_date: intake.spouse.parsed_birth_date)
        end

        if intake.spouse_last_four_ssn.blank? && intake.spouse.ssn.present?
          puts "============ updating encrypted_spouse_last_four_ssn"
          intake.update(spouse_last_four_ssn: intake.spouse.ssn_last_four)
        end

        SPOUSE_COLUMN_MAP.each do |intake_column, user_column|
          if intake[intake_column].blank? && intake.spouse[user_column].present?
            puts "============ updating #{intake_column}"
            intake.update(intake_column => intake.spouse[user_column])
          end
        end
      end
    end

    puts "~~~~~~~~~~~~ COMPLETE BACKFILL ~~~~~~~~~~~~"
  end
end