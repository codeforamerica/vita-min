module StateFile
  module Questions
    class CanceledDataTransferController < QuestionsController
      include IrsDataTransferLinksConcern

      def self.show?(_intake)
        false
      end

      def edit
        @link = data_transfer_link
      end

      def illustration_path
        "error-circle.svg"
      end

      private

      def form_class
        NullForm
      end

      def prev_path
        nil
      end
    end
  end
end