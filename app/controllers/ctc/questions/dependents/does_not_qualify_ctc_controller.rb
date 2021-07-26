module Ctc
  module Questions
    module Dependents
      class DoesNotQualifyCtcController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          return false unless dependent

          !dependent.qualifying_child? && !dependent.qualifying_relative?
        end

        def self.model_for_show_check(current_controller)
          current_resource_from_params(current_controller.visitor_record, current_controller.params)
        end

        def edit
          @dependent = current_dependent
          super
        end

        def update
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

# does-not-qualify-ctc
# http://ctc.localhost:3000/en/questions/dependents/34/does-not-qualify-ctc