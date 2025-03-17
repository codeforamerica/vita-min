module StateFile
  module Questions
    class W2Controller < QuestionsController
      before_action :allows_w2_editing, only: [:edit, :update]
      before_action :load_w2

      helper_method :box_14_codes_and_values, :state_wages_invalid?

      def self.show?(intake) # only accessed via button, not navigator
        false
      end

      def prev_path
        StateFile::Questions::IncomeReviewController.to_path_helper(return_to_review: params[:return_to_review])
      end

      def edit
        if StateFile::StateInformationService.check_box_16(current_state_code) && !current_intake.confirmed_w2_ids.include?(@w2.id)
          current_intake.confirmed_w2_ids.append(@w2.id)
          current_intake.save
        end

        @w2.valid?(:state_file_edit)
      end

      def show; end

      def update
        @w2.assign_attributes(form_params)
        @w2.check_box14_limits = true

        if @w2.valid?(:state_file_edit)
          @w2.box14_ui_hc_wd = nil
          @w2.save(context: :state_file_edit)
          redirect_to StateFile::Questions::IncomeReviewController.to_path_helper(return_to_review: params[:return_to_review])
        else
          render :edit
        end
      end

      def form_params
        params.require(StateFileW2.name.underscore)
              .except(:state_file_intake_id, :state_file_intake_type)
              .permit(*StateFileW2.attribute_names)
      end

      def box_14_codes_and_values
        @box14_codes.map do |code|
          code_name = code['name'].downcase
          field_name = "box14_#{code_name}"
          value = code_name == "uiwfswf" ? @w2.get_box14_ui_overwrite : @w2.send(field_name)
          { code_name:, field_name:, value: }
        end
      end

      def state_wages_invalid?
        StateFile::StateInformationService.check_box_16(current_state_code) && current_intake.state_wages_invalid?(@w2)
      end

      def load_w2
        @w2 = current_intake.state_file_w2s.find(params[:id])
        @box14_codes = StateFile::StateInformationService.w2_supported_box14_codes(current_state_code)
      end

      def allows_w2_editing
        unless current_intake.allows_w2_editing?
          redirect_to prev_path
        end
      end
    end
  end
end
