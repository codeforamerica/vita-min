module Ctc
  module Questions
    class IpPinEntryController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def form_params
        params.fetch(form_name, {}).permit(*form_class.attribute_names + [{ dependents_attributes: [:id, :ip_pin] }])
      end

      def illustration_path
        "issued-identity-pin.svg"
      end
    end
  end
end
