module StateFile
  module Questions
    class DependentDobAzController < QuestionsController
      layout "state_file/question"

      def edit
        @intake = current_intake
        @dependents = @intake.dependents
        @form = form_class.from_intake(@intake)
      end

      def update
        @form = form_class.new(current_intake, form_params)
        if @form.save && @form.valid?
          redirect_to next_path
        else
          render :edit
        end
      end

      def illustration_path; end

      private

      def form_params
        params.require(:state_file_az_dependents_dob_form).permit(dependents_attributes: [:id, :dob_month, :dob_day, :dob_year, :months_in_home])
      end

      def form_class
        StateFile::AzDependentsDobForm
      end

    end
  end
end
