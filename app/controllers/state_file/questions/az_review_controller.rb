module StateFile
  module Questions
    class AzReviewController < BaseReviewController
      def edit
        binding.pry
        @show_dependent_months_in_home = true
        super
      end
    end
  end
end
