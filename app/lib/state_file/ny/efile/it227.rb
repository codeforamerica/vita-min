module StateFile
  module Ny
    module Efile
      class It227 < ::Efile::TaxCalculator
        attr_accessor :lines, :value_access_tracker

        def initialize(value_access_tracker:, lines:)
          @value_access_tracker = value_access_tracker
          @lines = lines
        end

        def calculate
          set_line(:IT227_PART_2_LINE_1, -> { 0 })
        end
      end
    end
  end
end
