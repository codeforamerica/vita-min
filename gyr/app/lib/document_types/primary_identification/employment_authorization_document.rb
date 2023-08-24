module DocumentTypes
  module PrimaryIdentification
    class EmploymentAuthorizationDocument < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Employment Authorization Document"
        end
      end
    end
  end
end