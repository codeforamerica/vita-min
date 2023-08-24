module DocumentTypes
  module SecondaryIdentification
    class CertificateOfCitizenship < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Certificate of Citizenship"
        end
      end
    end
  end
end
