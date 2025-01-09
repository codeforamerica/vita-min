module Efile
  module Nj
    class NjStateWages
      def self.calculate_state_wages(intake)
        intake.state_file_w2s.sum do |w2|
          w2.state_wages_amount.to_i
        end
      end
    end
  end
end
