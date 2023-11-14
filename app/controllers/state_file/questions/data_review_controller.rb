module StateFile
  module Questions
    class DataReviewController < QuestionsController
      def edit
        super
      end

      def update
        binding.pry
        user_ip = request.remote_ip
        puts "***********"
        puts user_ip
        super
      end

      private

      def form_class
        StateFile::EfileDeviceInfoForm
      end

      def prev_path
        nil
      end
    end
  end
end
