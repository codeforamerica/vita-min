module Ctc
  module Questions
    module Dependents
      class ChildQualifiesController < BaseDependentController
        include AuthenticatedCtcClientConcern
        include RecaptchaScoreConcern

        layout "intake"

        def self.show?(dependent)
          return false unless dependent.present? && dependent.relationship.present?

          dependent.yr_2021_age >= 19
        end

        def illustration_path; end
      end
    end
  end
end