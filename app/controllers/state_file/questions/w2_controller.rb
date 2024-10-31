module StateFile
  module Questions
    class W2Controller < QuestionsController
      before_action :load_w2

      def edit; end

      def update
        @w2.assign_attributes(form_params)

        if @w2.valid?
          @w2.save
          redirect_to StateFile::Questions::IncomeReviewController.to_path_helper
        else
          render :edit
        end
      end

      def form_params
        params.require(StateFileW2.name.underscore)
              .except(:state_file_intake_id, :state_file_intake_type)
              .permit(*StateFileW2.attribute_names)
      end

      def load_w2
        @w2 = current_intake.state_file_w2s.find(params[:id])
        @box14_codes = StateFile::StateInformationService.w2_supported_box14_codes(current_state_code)
      end
    end
  end
end
