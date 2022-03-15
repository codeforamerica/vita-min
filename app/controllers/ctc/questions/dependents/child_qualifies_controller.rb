module Ctc
  module Questions
    module Dependents
      class ChildQualifiesController < BaseDependentController
        include AuthenticatedCtcClientConcern
        include RecaptchaScoreConcern

        layout "intake"

        def illustration_path; end
      end
    end
  end
end