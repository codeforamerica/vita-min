module Efile
  module Ny
    class It214 < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, direct_file_data:, intake:, nyc_full_year_resident:, claimed_as_dependent:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = direct_file_data
        @intake = intake
        @nyc_full_year_resident = nyc_full_year_resident
        @claimed_as_dependent = claimed_as_dependent
      end

      def calculate
        set_line(:IT214_LINE_1, @nyc_full_year_resident)
        set_line(:IT214_LINE_2,  @direct_file_data, :occupied_residence)
        set_line(:IT214_LINE_3,  @direct_file_data, :property_over_limit)
        set_line(:IT214_LINE_4,  @claimed_as_dependent)
        set_line(:IT214_LINE_5,  @direct_file_data, :public_housing)
        set_line(:IT214_LINE_6,  @direct_file_data, :nursing_home)
        set_line(:IT214_LINE_9, @direct_file_data, :fed_agi)
        set_line(:IT214_LINE_33, -> { 0 })
      end
    end
  end
end
