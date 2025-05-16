module StateFile
  module Questions
    class W2Controller < QuestionsController
      before_action :load_box_14_codes
      before_action :load_w2, only: [:show, :edit, :update]
      helper_method :box_14_codes_and_values, :state_wages_invalid?

      def self.show?(intake) # only accessed via button, not navigator
        false
      end

      def prev_path
        StateFile::Questions::IncomeReviewController.to_path_helper(return_to_review: params[:return_to_review])
      end

      def edit_all
        if params.include? current_intake.class.name.underscore
          current_intake.assign_attributes(all_w2_form_params)
        end
        current_intake.state_file_w2s.each do |w2|
          w2.valid?(:state_file_edit)
        end
      end

      def update_all
        current_intake.assign_attributes(all_w2_form_params)
        current_intake.state_file_w2s.each { |w2| w2.check_box14_limits = true }
        if current_intake.valid?(context: :state_file_edit)
          current_intake.state_file_w2s.each { |w2| w2.box14_ui_hc_wd = nil }
          current_intake.save(context: :state_file_edit)
          redirect_to(StateFile::Questions::IncomeReviewController.to_path_helper(return_to_review: params[:return_to_review]))
        else
          render :edit_all
        end
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

      def all_w2_form_params
        params.require(current_intake.class.name.underscore)
              .permit(state_file_w2s_attributes: StateFileW2.attribute_names)
      end

      def form_params
        params.require(StateFileW2.name.underscore)
              .except(:state_file_intake_id, :state_file_intake_type)
              .permit(*StateFileW2.attribute_names)
      end

      def box_14_codes_and_values(w2)
        @box14_codes.map do |code|
          code_name = code['name'].downcase
          field_name = "box14_#{code_name}"
          value = code_name == "uiwfswf" ? w2.get_box14_ui_overwrite : w2.send(field_name)
          { code_name:, field_name:, value: }
        end
      end

      def state_wages_invalid?(state_file_w2 = nil)
        state_file_w2 ||= @w2
        StateFile::StateInformationService.check_box_16(current_state_code) && current_intake.state_wages_invalid?(state_file_w2)
      end

      def load_box_14_codes
        @box14_codes = StateFile::StateInformationService.w2_supported_box14_codes(current_state_code)
      end

      def load_w2
        @w2 = current_intake.state_file_w2s.find(params[:id])
      end
    end
  end
end
