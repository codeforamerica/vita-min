module StateFile
  module Questions
    class NcReviewController < BaseReviewController
      def edit
        @show_dependent_months_in_home = false
        super
      end
    end
  end
end
