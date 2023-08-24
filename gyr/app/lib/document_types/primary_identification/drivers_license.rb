module DocumentTypes
  module PrimaryIdentification
    class DriversLicense < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Drivers License"
        end
      end
    end
  end
end