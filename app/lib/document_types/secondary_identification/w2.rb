module DocumentTypes
  module SecondaryIdentification
    class W2 < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "W2"
        end
      end
    end
  end
end
