module StateFile
  module Questions
    class AzQualifyingOrganizationContributionsController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def index
        @contribution_count = contributions.count
        redirect_to action: :new unless contributions.present?
      end

      def edit
        contribution.made_contributions = "yes"
      end

      def update
        contribution.assign_attributes(az321_contribution_params)

        if contribution.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :edit
        end
      end

      def new 
        @contribution = contributions.build(date_of_contribution_year: @filing_year)
      end

      def create
        @contribution = contributions.build(az321_contribution_params)

        return redirect_to next_path if @contribution.made_contributions == "no"

        if @contribution.save(context: :form_create)
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :new
        end
      end

      def destroy
        if contribution.destroy
          flash[:notice] = t('.removed', charity_name: contribution.charity_name)
        end

        redirect_to action: :index, return_to_review: params[:return_to_review]
      end

      def self.navigation_actions
        [:index, :new]
      end

      private

      def contributions
        @contributions ||= current_intake.az321_contributions
      end

      def contribution
        @contribution ||= contributions.find(params[:id])
      end

      def az321_contribution_params
        params.require(:az321_contribution).permit(
            :charity_name, :charity_code, :amount,
            :date_of_contribution_day, :date_of_contribution_month,
            :date_of_contribution_year, :made_contributions
          )
      end
    end
  end
end
