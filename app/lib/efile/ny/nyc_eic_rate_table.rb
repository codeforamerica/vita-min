module Efile
  module Ny
    class NycEicRateTable
      # https://www.tax.ny.gov/forms/current-forms/it/it215i.htm#nyc-eic-table

      class << self
        def find_row(ny_agi)
          ROWS.find do |r|
            r.agi_floor <= ny_agi && ny_agi < r.agi_ceiling
          end
        end
      end

      private

      EicRateTableRow = Struct.new(:agi_floor, :agi_ceiling, :line_2_amt, :line_5_amt, :line_6_amt)

      ROWS = [
        EicRateTableRow.new(-Float::INFINITY,           5_000,    nil,  nil, 0.30),
        EicRateTableRow.new(           5_000,           7_500,  4_999, 0.30,  nil),
        EicRateTableRow.new(           7_500,          15_000,    nil,  nil, 0.25),
        EicRateTableRow.new(          15_000,          17_500, 14_999, 0.25,  nil),
        EicRateTableRow.new(          17_500,          20_000,    nil,  nil, 0.20),
        EicRateTableRow.new(          20_000,          22_500, 19_999, 0.20,  nil),
        EicRateTableRow.new(          22_500,          40_000,    nil,  nil, 0.15),
        EicRateTableRow.new(          40_000,          42_500, 39_999, 0.15,  nil),
        EicRateTableRow.new(          42_500, Float::INFINITY,    nil,  nil, 0.10),
      ]
    end
  end
end
