module Ctc
  module Questions
    module Dependents
      class ChildDisqualifiersController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "intake"

        def self.show?(dependent)
          dependent.present? && dependent.relationship.present?
        end

        private

        def illustration_path; end
      end
    end
  end
end
