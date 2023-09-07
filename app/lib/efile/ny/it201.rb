module Efile
  module Ny
    class It201
      # TODO: Need name ideas; could be
      # - lines_already_filled_out
      # - input_lines
      # The purpose is that this stores the lines already filled out either
      # by the client or through data imports from the IRS Form 1040.
      attr_reader :lines

      def initialize(year, filing_status, lines, it227)
        @year = year

        @filing_status = filing_status # single, mfj, that's all we support for now
        @lines = ActiveSupport::HashWithIndifferentAccess.new(lines)
        validate_lines
        @lines["60E"] = it227.calculate()["part2_line1"]
      end

      def calculate
        # This is intended to be the one public method. Do we like the name?
        # I could imagine calling it `calculate_dynamic_lines` or `calc_tax`.
        #
        # The way I plan to implement it is that it returns a hash of lines
        # that are now available, so there's the `.lines` which is the data
        # we got as input, and the output of `.calculate` which is also a hash
        # of line number/name => value
        result = ActiveSupport::HashWithIndifferentAccess.new
        result
      end

      private

      def is_full_year_resident
        if filing_status_mfj?
          if lines["F_1_NBR"] == 12 && lines["F_2_NBR"] == 12
            true
          end
        else
          lines["F_1_NBR"] == 12
        end
      end

      def filing_status_mfj?
        @filing_status == :mfj
      end

      def validate_lines
        @lines.each_key do |line_name|
          data_type = line_name.split("_").last
          value = @lines[line_name]
          raise ArgumentError("value is invalid: #{line_name}=#{value}") unless validate_data_type(data_type, value)
        end
      end

      def validate_data_type(data_type, value)
        # I think it's going to be useful to have a suffix for each input line
        # to show its data format to avoid weird problems like '5'+'6'='56'.
        #
        # I got this idea from another tax math implementation.
        case data_type
        when "NBR"
          raise ArgumentError, "value #{value} is not a number" unless value.is_a?(Integer)
        end
      end
    end
  end
end
