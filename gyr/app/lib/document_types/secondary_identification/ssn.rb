module DocumentTypes
  module SecondaryIdentification
    class Ssn < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "SSN"
        end
      end
    end
  end
end
