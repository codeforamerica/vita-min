module SubmissionBuilder
  module BusinessLogicMethods
    include SubmissionBuilder::FormattingMethods

    def name_line_1(tax_return, intake)
      if tax_return.filing_jointly?
        name_line_1_type(intake.primary.first_name, intake.primary.middle_initial, intake.primary.last_name, intake.primary.suffix, intake.spouse.first_name, intake.spouse.middle_initial, intake.spouse.last_name)
      else
        name_line_1_type(intake.primary.first_name, intake.primary.middle_initial, intake.primary.last_name, intake.primary.suffix)
      end
    end

    # 0 - zero balance
    # 2 - bank account
    # 3 - check
    def refund_disbursement_code
      # Commenting this out because its not going to be correct for 2021 tax year. We might be able to just
      # always fill it out, even for 0 balance returns without issue. Or can replace with updated logic
      # return 0 if submission.tax_return.claimed_recovery_rebate_credit.zero?

      submission.intake.refund_payment_method_direct_deposit? ? 2 : 3
    end

    def oob_security_verification_code
      return "03" if submission.intake.email_address_verified_at.present?
      return "07" if submission.intake.sms_phone_number_verified_at.present?
    end

    # 0 - initiating IP == submission IP
    # 1 - initiating IP != submission IP
    def last_submission_rqr_oob_code
      submission.client.first_sign_in_ip == submission.client.last_sign_in_ip ? 0 : 1
    end

    # Converting DateTime to epoch time then subtracting provides distance of time in seconds
    # Divide by 60 to get distance of time in minutes
    def total_preparation_submission_minutes
      (DateTime.now.to_i - submission.client.created_at.to_datetime.to_i) / 60
    end

    def total_active_preparation_minutes
      current_session_duration = submission.client.last_seen_at.to_i - submission.client.current_sign_in_at.to_i
      ((submission.client.previous_sessions_active_seconds || 0) + current_session_duration) / 60
    end

    def state_file_total_preparation_submission_minutes
      (submission.created_at.to_datetime.to_i - submission.data_source.created_at.to_datetime.to_i) / 60
    end

    def spouse_name_control(intake)
      name = intake.use_primary_name_for_name_control ? intake.primary.last_name : intake.spouse.last_name
      name_control_type(name)
    end

    # This is likely only applicable to the latest tax year, and will need revision if we want to submit previous
    # tax years accurately.
    def spouse_prior_year_agi(intake, tax_year)

      if tax_year < 2021 && !ENV['TEST_SCHEMA_VALIDITY_ONLY']
        raise "spouse_prior_year_agi only works for current tax year"
      end

      intake.spouse_prior_year_agi_amount || 0
    end

    def primary_prior_year_agi(intake, tax_year)
      # When submitting e.g. a 2020 return in tax year 2021, we'd need to ask another question;
      # intake.primary_prior_year_agi_amount is only usable for the current tax year.
      if tax_year < 2021 && !ENV['TEST_SCHEMA_VALIDITY_ONLY']
        raise "primary_prior_year_agi only works for current tax year"
      end

      intake.primary_prior_year_agi_amount || 0
    end
  end
end