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
        @it227 = it227
        validate_lines
      end

      def calculate
        # This is intended to be the one public method. Do we like the name?
        # I could imagine calling it `calculate_dynamic_lines` or `calc_tax`.
        #
        # The way I plan to implement it is that it returns a hash of lines
        # that are now available, so there's the `.lines` which is the data
        # we got as input, and the output of `.calculate` which is also a hash
        # of line number/name => value
        @computed = ActiveSupport::HashWithIndifferentAccess.new
        @computed[:AMT_60E] = @it227.calculate[:part2_line1]
        # TODO: E_1_CBX
        @computed[:AMT_17] = compute_line_17
        @computed[:AMT_19] = compute_line_19
        @computed[:AMT_24] = compute_line_24
        @computed[:AMT_25] = @lines[:AMT_4]
        @computed[:AMT_27] = @lines[:AMT_15]
        @computed[:AMT_32] = compute_line_32
        @computed[:AMT_33] = compute_line_33
        @computed
      end

      private

      def compute_line_17
        result = 0
        (1..16).each do |line_num|
          next if line_num == 12
          result += lines["AMT_#{line_num}"]
        end

        result
      end

      def compute_line_19
        @computed[:AMT_17] - (@lines[:AMT_18]).abs
      end

      def compute_line_24
        result = 0
        result += @lines[:AMT_19A]
        (20..23).each do |line_num|
          result += lines["AMT_#{line_num}"]
        end
        result
      end

      def compute_line_32
        result = 0
        (25..31).each do |line_num|
          result += lines["AMT_line_num"]
        end
        result
      end

      def compute_line_33
        @computed[:AMT_24] - @computed[:AMT_32]
      end

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
