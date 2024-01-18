module Efile
  class TaxCalculator
    attr_reader :lines

    def line_or_zero(line)
      @lines[line.to_sym]&.value.to_i
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
        source_description = value_fn.source.strip_heredoc if @value_access_tracker.include_source
      end
      value, accesses = @value_access_tracker.with_tracking { value_fn.call }
      @lines[line_id] = TaxFormLine.new(line_id, value, source_description, accesses)
      @lines[line_id].value_access_tracker = @value_access_tracker
    end

    def filing_status_mfj?
      @filing_status == :married_filing_jointly
    end

    def filing_status_mfs?
      @filing_status == :married_filing_separately
    end

    def filing_status_single?
      @filing_status == :single
    end

    def filing_status_hoh?
      @filing_status == :head_of_household
    end

    def filing_status_qw?
      @filing_status == :qualifying_widow
    end
  end
end
