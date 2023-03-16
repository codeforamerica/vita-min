module DocumentTypes
  module PrimaryIdentification
    class Visa < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Visa"
        end
      end
    end
  end
end
