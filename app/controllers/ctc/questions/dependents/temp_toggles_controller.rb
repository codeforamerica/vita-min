module Ctc
  module Questions
    module Dependents
      class TempTogglesController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          false
        end

        private

        def illustration_path
        end
      end
    end
  end
end
