module Efile
  module Nj
    class NjStateWages
      NO_WAGES = -1

      def self.calculate_state_wages(intake)
        return NO_WAGES if intake.state_file_w2s.empty?

        intake.state_file_w2s.sum do |w2|
          w2.state_wages_amount
        end
      end
    end
  end
end
