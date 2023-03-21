module DocumentTypes
  module SecondaryIdentification
    class Ssa1099 < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "SSA 1099 for ID"
        end
      end
    end
  end
end
