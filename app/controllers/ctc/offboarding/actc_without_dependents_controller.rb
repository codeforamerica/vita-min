module Ctc
  module Offboarding
    class ActcWithoutDependentsController < CtcController
      helper_method :illustration_path, :illustration_folder, :prev_path

      layout "intake"

      def show; end

      def file_with_gyr
        SystemNote.create(client: current_client, body: "Client clicked File with GetYourRefund button on #{Time.zone.now.strftime("%-m/%-d/%Y")} at #{Time.zone.now.strftime("%l:%M %p").strip}")
        redirect_to root_with_source_url(host: MultiTenantService.new(:gyr).host, source: "received_ctc"), allow_other_host: true
      end

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
