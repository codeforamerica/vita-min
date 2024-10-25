module Efile
  module Nj
    class NjStateWages
      NO_WAGES = -1

      def self.calculate_state_wages(intake)
        return NO_WAGES if intake.direct_file_data.w2s.empty?

        intake.direct_file_data.w2s.sum do |w2|
          w2.node.at("W2StateLocalTaxGrp StateWagesAmt").text.to_i
        end
      end
    end
  end
end