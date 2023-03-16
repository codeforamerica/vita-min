module DocumentTypes
  module PrimaryIdentification
    class Passport < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Passport"
        end
      end
    end
  end
end