module DocumentTypes
  module SecondaryIdentification
    class SsaNotice < DocumentTypes::SecondaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "SSA Notice"
        end
      end
    end
  end
end
