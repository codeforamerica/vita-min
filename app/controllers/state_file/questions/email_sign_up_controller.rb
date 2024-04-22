module StateFile
  module Questions
    class EmailSignUpController < QuestionsController

      def self.show?(intake)
        intake.contact_preference == "email"
      end

      def edit
        # Show the email address form
        super
      end

      def create
        # Send a verification code to the email address
        # Show the form which will collect the verification code
        @form = initialized_update_form
        if @form.valid?
          send_verification_code
        else
          after_update_failure
          track_validation_error
          render :edit
        end
      end

      def update
        @form = initialized_update_form
        if @form.valid? && @form.verification_code_valid?
          intake = current_intake
          existing_intake = get_existing_intake(intake, @form.contact_info)
          if existing_intake.present?
            redirect_into_login(@form.contact_info, intake, existing_intake)
            return
          end
          @form.save
          after_update_success
          track_question_answer
          redirect_to(next_path)
        else
          after_update_failure
          track_validation_error
          render :create
        end
      end

      private

      def send_verification_code
        RequestVerificationCodeEmailJob.perform_later(
          email_address: @form.email_address,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end

      def get_existing_intake(intake, contact_info)
        search = intake.class.where.not(id: intake.id)
        search = search.where(email_address: contact_info)
        search.first
      end

      def redirect_into_login(contact_info, intake, existing_intake)
        hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(
          @form.contact_info, @form.verification_code
        )
        @form.intake = existing_intake
        intake.destroy unless intake.id == existing_intake.id
        sign_in existing_intake
        if existing_intake.raw_direct_file_data.present?
          redirect_to IntakeLoginsController.to_path_helper(
            action: :edit,
            id: hashed_verification_code,
            us_state: params[:us_state]
          )
        else
          redirect_to(next_path)
        end
      end

      def after_update_success
        messaging_service = StateFile::MessagingService.new(
          message: StateFile::AutomatedMessage::Welcome,
          intake: current_intake,
          sms: false,
          email: true,
          body_args: {intake_id: current_intake.id}
        )
        messaging_service.send_message
      end
    end
  end
end