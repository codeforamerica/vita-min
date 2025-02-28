module StateFile
  module Questions
    class AzReviewController < BaseReviewController
      def edit
        @show_dependent_months_in_home = true
        super
      end
    end
  end
end
