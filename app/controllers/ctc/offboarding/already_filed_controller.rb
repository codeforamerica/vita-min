module Ctc
  module Offboarding
    class AlreadyFiledController < CtcController
      helper_method :illustration_path, :illustration_folder, :prev_path

      layout "intake"

      def show; end

      def illustration_path
        "warning-triangle-yellow.svg"
      end

      def illustration_folder
        "questions"
      end

      def prev_path
        nil
      end
    end
  end
end