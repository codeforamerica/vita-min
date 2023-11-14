module StateFile
  module Questions
    class TaxRefundController < QuestionsController

      def form_class
        DepositTypeForm
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end
