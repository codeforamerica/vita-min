module Ctc
  module Offboarding
    class AlreadyFiledController < CtcController
      helper_method :illustration_path, :illustration_folder

      layout "intake"

      def show; end

      def illustration_path
        "hand-holding-check.svg"
      end

      def illustration_folder
        "questions"
      end
    end
  end
end