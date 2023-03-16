module DocumentTypes
  module PrimaryIdentification
    class StateId < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "State ID"
        end
      end
    end
  end
end