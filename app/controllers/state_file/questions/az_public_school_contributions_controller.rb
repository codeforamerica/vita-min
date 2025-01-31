module StateFile
  module Questions
    class AzPublicSchoolContributionsController < QuestionsController
      include ReturnToReviewConcern

      def self.navigation_actions
        [:index, :new]
      end

      def index
        @az322_contributions = current_intake.az322_contributions
        unless @az322_contributions.present?
          build_contribution
          render :new
        end
      end

      def new
        build_contribution
      end

      def build_contribution
        if session[:selected_no_on_school_contributions]
          @az322_contribution = current_intake.az322_contributions.build(made_contribution: "no")
        else
          @az322_contribution = current_intake.az322_contributions.build
        end
      end

      def create
        if params[:az322_contribution].present?
          @az322_contribution = current_intake.az322_contributions.build(az322_contribution_params)
          @az322_contributions = current_intake.az322_contributions
          if @az322_contribution.made_contribution_no?
            session[:selected_no_on_school_contributions] = true
            return redirect_to next_path
          end

          if current_intake.valid?(:az322) && @az322_contribution.valid?
            @az322_contribution.save
            redirect_to action: :index, return_to_review: params[:return_to_review]
          else
            render :new
          end
        else
          build_contribution
          render :new
        end
      end

      def edit
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
      end

      def update
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
        @az322_contribution.assign_attributes(az322_contribution_params)

        if @az322_contribution.made_contribution_no?
          session[:selected_no_on_school_contributions] = true
          @az322_contribution.destroy
          return redirect_to action: :index, return_to_review: params[:return_to_review]
        end

        if @az322_contribution.valid?
          @az322_contribution.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :edit
        end
      end

      def destroy
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
        if @az322_contribution.destroy
          flash[:notice] = I18n.t("state_file.questions.az_public_school_contributions.destroy.removed", school_name: @az322_contribution.school_name)
        end
        redirect_to action: :index, return_to_review: params[:return_to_review]
      end

      private

      def az322_contribution_params
        params.require(:az322_contribution).permit(
          :made_contribution,
          :school_name,
          :ctds_code,
          :district_name,
          :amount,
          :date_of_contribution_day,
          :date_of_contribution_month,
          :date_of_contribution_year
        )
      end
    end
  end
end