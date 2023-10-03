module Efile
  class TaxCalculator
    attr_reader :lines

    private

    def set_line(line_id, value_fn)
      source_description = nil
      if value_fn.is_a?(Symbol)
        value_fn = method(value_fn)
      else
        method_name = "calculate_#{line_id.to_s.sub('AMT_', 'line_').downcase}".to_sym
        method =
          begin
            self.class.instance_method(method_name)
          rescue NameError
            nil
          end
        source_description = method&.source&.strip_heredoc
      end
      source_description ||= value_fn.source.strip_heredoc

      value, accesses = @value_access_tracker.with_tracking { value_fn.call }
      @lines[line_id] = TaxFormLine.new(line_id, value, source_description, accesses)
      @lines[line_id].value_access_tracker = @value_access_tracker
    end

    def filing_status_mfj?
      @filing_status == :married_filing_jointly
    end

    def filing_status_single?
      @filing_status == :single
    end

    def line_or_zero(line)
      @lines[line.to_sym]&.value || 0
    end
  end
end
