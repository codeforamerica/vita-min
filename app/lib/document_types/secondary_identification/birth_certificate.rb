module DocumentTypes
  module SecondaryIdentification
    class BirthCertificate < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Birth Certificate"
        end
      end
    end
  end
end
