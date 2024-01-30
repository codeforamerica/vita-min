module StateFile
  module Questions
    class VerificationCodeController < QuestionsController
      def edit
        # TODO: Sending a code here feels icky. By convention, edit trigger mutations
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
            if intake.contact_preference == "email"
              contact_info = intake.email_address
            else
              contact_info = intake.phone_number
            end
            hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(contact_info, @form.verification_code)
            @form.intake = existing_intake
            intake.destroy
            session[:state_file_intake] = existing_intake.id
            redirect_to IntakeLoginsController.to_path_helper(action: :edit, id: hashed_verification_code, **{
              us_state: params[:us_state]
            })
            return
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

      def get_existing_intake(intake)
        search = intake.class.where.not(id: intake.id, raw_direct_file_data: nil)
        search = search.where(phone_number: intake.phone_number) if intake.phone_number.present?
        search = search.where(email_address: intake.email_address) if intake.email_address.present?
        search.first
      end

    end
  end
end