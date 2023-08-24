module Ctc
  module Questions
    class IpPinController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def form_params
        params.fetch(form_name, {}).permit(*form_class.attribute_names + [{ dependents_attributes: [:id, :has_ip_pin] }])
      end

      def illustration_path
        "issued-identity-pin.svg"
      end
    end
  end
end
