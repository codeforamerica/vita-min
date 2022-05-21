module Ctc
  module Offboarding
    class ActcWithoutDependentsController < CtcController
      helper_method :illustration_path, :illustration_folder, :prev_path

      layout "intake"

      def show; end

      def illustration_path
      end

      def illustration_folder
      end

      def prev_path
        nil
      end
    end
  end
end