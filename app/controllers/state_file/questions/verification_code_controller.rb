module StateFile
  module Questions
    class VerificationCodeController < QuestionsController
      def edit
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
            @form.intake = existing_intake
            intake.destroy
            session[:state_file_intake] = existing_intake.to_global_id
            sign_in existing_intake
          end
          @form.save
          after_update_success
          track_question_answer
          target_path = next_path
          if existing_intake.present?
            target_controller = existing_intake.controller_for_current_step
            flow = form_navigation.controllers
            if flow.find_index(self.class) >= flow.find_index(target_controller)
              target_path = path_for_step(target_controller)
            end
          end
          if existing_intake.present?
            session.delete(:state_file_intake)
          end
          redirect_to(target_path)
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