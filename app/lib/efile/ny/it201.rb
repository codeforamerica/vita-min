module Efile
  module Ny
    class It201
      # TODO: Need name ideas; could be
      # - lines_already_filled_out
      # - input_lines
      # The purpose is that this stores the lines already filled out either
      # by the client or through data imports from the IRS Form 1040.
      attr_reader :lines

      def initialize(year, filing_status, claimed_as_dependent, dependent_count, lines, it227)
        @year = year

        @filing_status = filing_status # single, mfj, that's all we support for now
        @claimed_as_dependent = claimed_as_dependent # true/false
        @dependent_count = dependent_count # number
        @lines = ActiveSupport::HashWithIndifferentAccess.new(lines)
        @it227 = it227
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
        @computed[:AMT_17] = calculate_line_17
        @computed[:AMT_19] = calculate_line_19
        @computed[:AMT_24] = calculate_line_24
        @computed[:AMT_25] = @lines[:AMT_4]
        @computed[:AMT_27] = @lines[:AMT_15]
        @computed[:AMT_32] = calculate_line_32
        @computed[:AMT_33] = calculate_line_33
        @computed[:AMT_34] = calculate_line_34
        @computed[:AMT_35] = calculate_line_35
        @computed[:AMT_36] = @dependent_count
        @computed[:AMT_37] = calculate_line_37
        @computed[:AMT_38] = @computed[:AMT_37]
        @computed[:AMT_39] = calculate_line_39
        @computed[:AMT_43] = @computed[:AMT_40] + @computed[:AMT_41] + @computed[:AMT_42]
        @computed[:AMT_44] = [@computed[:AMT_39] - @computed[:AMT_43], 0].max
        @computed
      end

      private

      def calculate_line_17
        result = 0
        (1..16).each do |line_num|
          next if line_num == 12
          result += lines["AMT_#{line_num}"]
        end

        result
      end

      def calculate_line_19
        @computed[:AMT_17] - (@lines[:AMT_18]).abs
      end

      def calculate_line_24
        result = 0
        result += @lines[:AMT_19A]
        (20..23).each do |line_num|
          result += lines["AMT_#{line_num}"]
        end
        result
      end

      def calculate_line_32
        result = 0
        (25..31).each do |line_num|
          result += lines["AMT_line_num"]
        end
        result
      end

      def calculate_line_33
        @computed[:AMT_24] - @computed[:AMT_32]
      end

      def calculate_line_34
        case @filing_status
        when :single
          if @claimed_as_dependent
            3100
          else
            8000
          end
        when :mfj
          16050
        end
      end

      def calculate_line_35
        result = @computed[:AMT_33] - @computed[:AMT_34]
        [result, 0].max
      end

      def calculate_line_37
        result = @computed[:AMT_35] - (@computed[:AMT_36] * 1000)
        [result, 0].max
      end

      def calculate_line_39
        # aka calctax
        1 # TODO
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
    end
  end
end
