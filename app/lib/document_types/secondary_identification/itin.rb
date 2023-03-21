module DocumentTypes
  module SecondaryIdentification
    class Itin < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "ITIN"
        end
      end
    end
  end
end
