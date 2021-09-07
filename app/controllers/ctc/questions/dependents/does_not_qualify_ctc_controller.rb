module Ctc
  module Questions
    module Dependents
      class DoesNotQualifyCtcController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          return false unless dependent&.relationship

          !dependent.qualifying_child_2020? && !dependent.qualifying_relative_2020?
        end

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
