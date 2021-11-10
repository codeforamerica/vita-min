module Ctc
  module Questions
    module Dependents
      class DoesNotQualifyCtcController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          return false unless dependent&.relationship

          (!dependent.yr_2020_qualifying_child? && !dependent.yr_2020_qualifying_relative?) || dependent.birth_date.year == 2021
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
