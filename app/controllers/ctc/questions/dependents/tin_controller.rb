module Ctc
  module Questions
    module Dependents
      class TinController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          return false unless dependent&.relationship
          return false unless dependent.intake.had_dependents_yes?

          dependent.yr_2020_qualifying_child? || dependent.yr_2020_qualifying_relative?
        end

        private

        def illustration_path; end
      end
    end
  end
end
