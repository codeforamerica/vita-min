module StateFile
  module Questions
    class VerificationCodeController < QuestionsController
      def edit
        # TODO: Sending a code here feels icky. By convention, edit should not trigger mutations
        case current_intake.contact_preference
        when "text"
          RequestVerificationCodeTextMessageJob.perform_later(
            phone_number: current_intake.phone_number,
            locale: I18n.locale,
            visitor_id: current_intake.visitor_id,
            client_id: nil,
            service_type: :statefile
          )
          @contact_info = PhoneParser.formatted_phone_number(current_intake.phone_number)
        when "email"
          RequestVerificationCodeEmailJob.perform_later(
            email_address: current_intake.email_address,
            locale: I18n.locale,
            visitor_id: current_intake.visitor_id,
            client_id: nil,
            service_type: :statefile
          )
          @contact_info = current_intake.email_address
        end
        super
      end

      def update
        @form = initialized_update_form
        if @form.valid?
          intake = current_intake
          existing_intake = get_existing_intake(intake)
          if existing_intake.present?
            redirect_into_login(intake, existing_intake) and return
          end
          @form.save
          after_update_success
          track_question_answer
          redirect_to(next_path)
        else
          after_update_failure
          track_validation_error
          render :edit
        end
      end

      private

      def get_existing_intake(intake)
        return nil if intake.email_address.nil? && intake.phone_number.nil?

        # we don't help new york any more
        state_intake_classes = StateFile::StateInformationService.state_intake_classes.without(StateFileNyIntake)
        state_intake_classes.each do |intake_class|
          search = case intake.contact_preference
            when "text"
              intake_class.where.not(id: intake.id).where.not(raw_direct_file_data: nil).where(phone_number: intake.phone_number)
            when "email"
              intake_class.where.not(id: intake.id).where.not(raw_direct_file_data: nil).where(email_address: intake.email_address)
            end

          existing_intake = search.first
          return existing_intake if existing_intake
        end

        nil
      end

      def redirect_into_login(intake, existing_intake)
        contact_info = (
          if intake.contact_preference == "email"
            intake.email_address
          else
            intake.phone_number
          end
        )
        hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(
          contact_info, @form.verification_code
        )
        @form.intake = existing_intake
        intake.destroy unless intake.id == existing_intake.id
        redirect_to IntakeLoginsController.to_path_helper(
          action: :edit,
          id: hashed_verification_code
        )
      end
    end
  end
end