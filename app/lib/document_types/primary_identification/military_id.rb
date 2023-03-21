module DocumentTypes
  module PrimaryIdentification
    class MilitaryId < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Military ID"
        end
      end
    end
  end
end