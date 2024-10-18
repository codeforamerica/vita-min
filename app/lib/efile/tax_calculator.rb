module Efile
  class TaxCalculator
    attr_reader :lines

    def initialize(year:, intake:, include_source: false)
      @year = year
      @intake = intake
      @filing_status = intake.filing_status.to_sym
      @dependent_count = intake.dependents.length
      @direct_file_data = intake.direct_file_data
      intake.state_file_w2s.each do |w2|
        dest_w2 = @direct_file_data.w2s[w2.w2_index]
        dest_w2.node.at("W2StateLocalTaxGrp").inner_html = w2.state_tax_group_xml_node
      end
      @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
      @lines = HashWithIndifferentAccess.new
    end

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
        # TODO: replace .source with parser gem for more concise explanation of calculations
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
