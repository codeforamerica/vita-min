module Ctc
  module Questions
    module Dependents
      class TinController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          return false if dependent.nil?
          return false unless dependent.intake.had_dependents_yes?

          dependent.qualifying_child_2020? || dependent.qualifying_relative_2020?
        end

        private

        def illustration_path; end
      end
    end
  end
end
