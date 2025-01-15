module StateFile
  module NjPropertyTaxFlowOffRamp
    class << self
      def next_controller(options)
        if options[:return_to_review].present?
          StateFile::Questions::NjReviewController.to_path_helper
        else
          StateFile::Questions::NjSalesUseTaxController.to_path_helper(options)
        end
      end
    end
  end
end