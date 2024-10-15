module StateFile
  module Questions
    class MdCountyController < QuestionsController
      include ReturnToReviewConcern
      def edit
        @filing_year = Rails.configuration.statefile_current_tax_year
        @counties = current_intake.counties_for_select
        @subdivisions = current_intake.subdivisions_for_select
        super
      end

      def update
        # Make sure to re-initialize the dropdowns here in case of an error
        @counties = current_intake.counties_for_select
        @subdivisions = current_intake.subdivisions_for_select

        # Continue with the usual update logic
        if @form.update(form_params)
          redirect_to next_path
        else
          render :edit
        end
      end
    end
  end
end