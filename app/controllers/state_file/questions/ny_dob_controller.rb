module StateFile
  module Questions
    class NyDobController < QuestionsController
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
        params.require(:state_file_ny_dob_form).permit(
          :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year,
          :spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year,
          dependents_attributes: [:id, :dob_month, :dob_day, :dob_year])
      end

      def form_class
        StateFile::NyDobForm
      end

    end
  end
end