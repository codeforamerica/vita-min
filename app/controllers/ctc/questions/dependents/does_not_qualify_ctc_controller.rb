module Ctc
  module Questions
    module Dependents
      class DoesNotQualifyCtcController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def edit
          @dependent = current_resource
          super
        end

        private

        def form_class
          NullForm
        end

        def illustration_path; end
      end
    end
  end
end
