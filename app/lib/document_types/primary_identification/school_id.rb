module DocumentTypes
  module PrimaryIdentification
    class SchoolId < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "School ID"
        end
      end
    end
  end
end
