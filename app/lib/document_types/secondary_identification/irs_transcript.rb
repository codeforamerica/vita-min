module DocumentTypes
  module SecondaryIdentification
    class IrsTranscript < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "IRS Transcript"
        end
      end
    end
  end
end
