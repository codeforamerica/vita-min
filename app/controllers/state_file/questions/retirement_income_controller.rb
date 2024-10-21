module StateFile
  module Questions
    class RetirementIncomeController < QuestionsController
      def edit
        @state_file1099_r = current_intake.state_file1099_rs.find(params[:id])
      end

      def update
        @state_file1099_g = current_intake.state_file1099_gs.find(params[:id])
        @state_file1099_g.assign_attributes(state_file1099_params)

        if @state_file1099_g.had_box_11_no?
          @state_file1099_g.destroy
          return redirect_to action: :index, return_to_review: params[:return_to_review]
        end

        if @state_file1099_g.valid?
          @state_file1099_g.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :edit
        end
      end

      private

      def state_file1099_params
        state_file_params = params.require(:state_file1099_r).permit(
          #
        )
      end
    end
  end
end
