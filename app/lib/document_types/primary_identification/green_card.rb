module DocumentTypes
  module PrimaryIdentification
    class GreenCard < DocumentTypes::PrimaryIdentification::Base
      class << self
        def relevant_to?(_intake)
          false # only used as an alternative ID type
        end

        def key
          "Green Card"
        end
      end
    end
  end
end