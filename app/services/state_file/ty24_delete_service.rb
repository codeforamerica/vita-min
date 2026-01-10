# frozen_string_literal: true

module StateFile
  class Ty24DeleteService
    INTAKE_MAP = StateFile::Ty24ArchiverService::INTAKE_MAP

    attr_reader :state_code, :intake_class, :tax_year, :start_date, :end_date

    def initialize(state_code:)
      @state_code = state_code.to_s.downcase
      @intake_class = INTAKE_MAP[@state_code.to_sym]
      @tax_year = 2024

      et = ActiveSupport::TimeZone["America/New_York"]
      @start_date = et.parse("2025-01-15 00:00:00")
      @end_date   = et.parse("2025-10-25 23:59:59")
    end

    def self.call(state_code:)
      new(state_code: state_code).call
    end

    def call
      intake_class
        .where(created_at: start_date..end_date)
        .in_batches(of: 1000)
        .delete_all
    end
  end
end
