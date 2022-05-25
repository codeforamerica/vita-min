module Ctc
  module Offboarding
    class PuertoRicoSignUpController < CtcController
      helper_method :illustration_path, :illustration_folder, :prev_path

      layout "intake"

      def show; end

      def illustration_path
        "calendar-check.svg"
      end

      def illustration_folder
        "questions"
      end

      def prev_path
        questions_main_home_path
      end
    end
  end
end