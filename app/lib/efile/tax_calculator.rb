module Efile
  class TaxCalculator
    attr_reader :lines

    def initialize(year:, intake:, include_source: false)
      @year = year
      @intake = intake
      @filing_status = intake.state_filing_status
      @dependent_count = intake.dependents.length
      @direct_file_data = intake.direct_file_data
      @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
      @lines = HashWithIndifferentAccess.new
    end

    def line_or_zero(line)
      @lines[line.to_sym]&.value.to_i
    end

    delegate :refund_line, :owed_line, to: :class
    class << self
      attr_accessor :refund_line, :owed_line

      def set_refund_owed_lines(refund:, owed:)
        self.refund_line = refund
        self.owed_line = owed
      end
    end

    # if amount is positive they get a refund
    # if amount is negative they owe taxes
    # so we subtract owed from refund since one of them should always be 0
    def refund_or_owed_amount
      # TEMP: we will stub the amount and allow these to be undefined for now but when the calculators are complete we should raise
      # an error along the lines of "child classes must define these"
      return 0 unless refund_line.present? && owed_line.present?

      line_or_zero(refund_line) - line_or_zero(owed_line)
    end

    private

    def set_line(line_id, value_fn_or_data_source, field = nil)
      source_description = nil
      if field
        data_source = value_fn_or_data_source
        value_fn = -> { data_source.send(field) }
        source_description = "#{data_source.class}##{field}"
      else
        value_fn = value_fn_or_data_source
        if value_fn.is_a?(Symbol)
          value_fn = method(value_fn_or_data_source)
        end
        # TODO: replace .source with parser gem for more concise explanation of calculations
        source_description = value_fn.source.strip_heredoc if @value_access_tracker.include_source
      end
      value, accesses = @value_access_tracker.with_tracking { value_fn.call }
      @lines[line_id] = TaxFormLine.new(line_id, value, source_description, accesses)
      @lines[line_id].value_access_tracker = @value_access_tracker
    end

    def state_filing_status_mfj?
      @filing_status == :married_filing_jointly
    end

    def state_filing_status_mfs?
      @filing_status == :married_filing_separately
    end

    def state_filing_status_single?
      @filing_status == :single
    end

    def state_filing_status_hoh?
      @filing_status == :head_of_household
    end

    def state_filing_status_qw?
      @filing_status == :qualifying_widow
    end

    def state_filing_status_dependent?
      @filing_status == :dependent
    end
  end
end
