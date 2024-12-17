module Efile
  module Md
    class Md502crCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_data = intake.direct_file_data
        @filing_status = intake.filing_status.to_sym
      end

      def calculate
        set_line(:MD502CR_PART_M_LINE_1, :calculate_md502_cr_part_m_line_1)
        set_line(:MD502CR_PART_B_LINE_2, @direct_file_data, :fed_credit_for_child_and_dependent_care_amount)
        set_line(:MD502CR_PART_B_LINE_3, :calculate_md502_cr_part_b_line_3)
        set_line(:MD502CR_PART_B_LINE_4, :calculate_md502_cr_part_b_line_4)
        set_line(:MD502CR_PART_AA_LINE_2, :calculate_part_aa_line_2)
        set_line(:MD502CR_PART_AA_LINE_13, :calculate_part_aa_line_13)
        set_line(:MD502CR_PART_AA_LINE_14, :calculate_part_aa_line_14)
        set_line(:MD502CR_PART_CC_LINE_7, :calculate_part_cc_line_7)
        set_line(:MD502CR_PART_CC_LINE_8, :calculate_part_cc_line_8)
        set_line(:MD502CR_PART_CC_LINE_10, :calculate_part_cc_line_10)
      end

      private

      # filing status /	filer >= 65 /	spouse >= 65 /	agi <= threshold /	credit amount
      # mfj/qss/hoh	T	T	T	1750
      # mfj/qss/hoh	T	T	F	0
      # mfj/qss/hoh	T	F	T	1000
      # mfj/qss/hoh	T	F	F	0
      # mfj/qss/hoh	F	T	T	1000
      # mfj/qss/hoh	F	T	F	0
      # mfj/qss/hoh	F	F	T	0
      # mfj/qss/hoh	F	F	F	0
      # single/mfs	T	X	T	1000
      # single/mfs	T	X	F	0
      # single/mfs	F	X	T	0
      # single/mfs	F	X	F	0
      def calculate_md502_cr_part_m_line_1
        agi = line_or_zero(:MD502_LINE_1)
        credit = 0
        if (filing_status_mfj? || filing_status_qw? || filing_status_hoh?) && agi <= 150_000
          if @intake.primary_senior? && @intake.spouse_senior?
            credit = 1750
          elsif @intake.primary_senior? ^ @intake.spouse_senior?
            credit = 1000
          end
        elsif (filing_status_single? || filing_status_mfs?) && agi <= 100_000
          if @intake.primary_senior?
            credit = 1000
          end
        end
        credit
      end

      def calculate_md502_cr_part_b_line_3
        table_from_pdf = <<~PDF_COPY
          $0 $30,001 0.3200 $0 $50,001
          $30,001 $32,001 0.3168 $50,001 $53,001
          $32,001 $34,001 0.3136 $53,001 $56,001
          $34,001 $36,001 0.3104 $56,001 $59,001
          $36,001 $38,001 0.3072 $59,001 $62,001
          $38,001 $40,001 0.3040 $62,001 $65,001
          $40,001 $42,001 0.3008 $65,001 $68,001
          $42,001 $44,001 0.2976 $68,001 $71,001
          $44,001 $46,001 0.2944 $71,001 $74,001
          $46,001 $48,001 0.2912 $74,001 $77,001
          $48,001 $50,001 0.2880 $77,001 $80,001
          $50,001 $52,001 0.2848 $80,001 $83,001
          $52,001 $54,001 0.2816 $83,001 $86,001
          $54,001 $56,001 0.2784 $86,001 $89,001
          $56,001 $58,001 0.2752 $89,001 $92,001
          $58,001 $60,001 0.2720 $92,001 $95,001
          $60,001 $62,001 0.2688 $95,001 $98,001
          $62,001 $64,001 0.2656 $98,001 $101,001
          $64,001 $66,001 0.2624 $101,001 $104,001
          $66,001 $68,001 0.2592 $104,001 $107,001
          $68,001 $70,001 0.2560 $107,001 $110,001
          $70,001 $72,001 0.2528 $110,001 $113,001
          $72,001 $74,001 0.2496 $113,001 $116,001
          $74,001 $76,001 0.2464 $116,001 $119,001
          $76,001 $78,001 0.2432 $119,001 $122,001
          $78,001 $80,001 0.2400 $122,001 $125,001
          $80,001 $82,001 0.2368 $125,001 $128,001
          $82,001 $84,001 0.2336 $128,001 $131,001
          $84,001 $86,001 0.2304 $131,001 $134,001
          $86,001 $88,001 0.2272 $134,001 $137,001
          $88,001 $90,001 0.2240 $137,001 $140,001
          $90,001 $92,001 0.2208 $140,001 $143,001
          $92,001 $94,001 0.2176 $143,001 $146,001
          $94,001 $96,001 0.2144 $146,001 $149,001
          $96,001 $98,001 0.2112 $149,001 $152,001
          $98,001 $100,001 0.2080 $152,001 $155,001
          $100,001 $102,001 0.2048 $155,001 $158,001
          $102,001 $103,001 0.2016 $158,001 $161,001
          $103,001 $104,001 0.1984 $161,001 $164,001
          $104,001 $105,001 0.1952 $164,001 $167,001
          $105,001 $106,001 0.1920 $167,001 $169,901
          $106,001 $107,001 0.1888 0.0 0.0
          $107,001 $108,001 0.1856 0.0 0.0
          $108,001 $109,001 0.1824 0.0 0.0
          $109,001 $109,301 0.1792 0.0 0.0
          $109,301 inf 0.0000 $169,901 inf
        PDF_COPY

        row = Struct.new(:non_mfj_floor, :non_mfj_ceiling, :decimal, :mfj_floor, :mfj_ceiling)

        agi_bands = table_from_pdf.lines.map do |line|
          agi_band = line.split(" ")
          agi_band = agi_band.map { |item| item.gsub(/[$,]/, "").to_d }
          row.new(*agi_band)
        end

        agi_bands[0].mfj_floor = -Float::INFINITY
        agi_bands[0].non_mfj_floor = -Float::INFINITY
        agi_bands[-1].mfj_ceiling = Float::INFINITY
        agi_bands[-1].non_mfj_ceiling = Float::INFINITY

        agi = line_or_zero(:MD502_LINE_1)
        agi_band = agi_bands.find do |row|
          if filing_status_mfj?
            row.mfj_floor <= agi && agi < row.mfj_ceiling
          else
            row.non_mfj_floor <= agi && agi < row.non_mfj_ceiling
          end
        end

        agi_band.decimal
      end

      def calculate_md502_cr_part_b_line_4
        (line_or_zero(:MD502CR_PART_B_LINE_2) * @lines[:MD502CR_PART_B_LINE_3]&.value).round(0)
      end

      def calculate_part_aa_line_2
        @lines[:MD502CR_PART_B_LINE_4]&.value
      end

      def calculate_part_aa_line_13
        @lines[:MD502CR_PART_M_LINE_1]&.value
      end

      def calculate_part_aa_line_14
        line_or_zero(:MD502CR_PART_AA_LINE_2) + line_or_zero(:MD502CR_PART_AA_LINE_13)
      end

      def calculate_part_cc_line_7
        qualifying_fed_agi_limit = filing_status_mfj? ? 89_100 : 59_400

        return unless @direct_file_data.fed_agi <= qualifying_fed_agi_limit
        [line_or_zero(:MD502CR_PART_B_LINE_4) - line_or_zero(:MD502_LINE_21), 0].max
      end

      def calculate_part_cc_line_8
        return if @direct_file_data.fed_agi > 15_000

        qualifiying_children = @intake.dependents.count do |dependent|
          @intake.calculate_age(dependent.dob, inclusive_of_jan_1: false) < 6
        end

        qualifiying_children * 500
      end

      def calculate_part_cc_line_10
        (1..9).sum { |line_num| line_or_zero("MD502CR_PART_CC_LINE_#{line_num}") }
      end
    end
  end
end
