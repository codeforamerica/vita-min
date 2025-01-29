module StateFile
  module Nj2450Helper
    def line_name(line, primary_or_spouse)
      return :"#{line}_SPOUSE" if primary_or_spouse == :spouse
      :"#{line}_PRIMARY"
    end

    def get_persons_w2s(intake, primary_or_spouse)
      ssn = primary_or_spouse == :primary ? intake.primary.ssn : intake.spouse.ssn
      intake.state_file_w2s.all&.select { |w2| w2.employee_ssn == ssn }
    end

    def get_employer_name(w2, truncate: false)
      truncate ? sanitize_for_xml(w2.employer_name, 35) : w2.employer_name
    end

    def get_wages(w2)
      w2.wages&.round
    end

    def get_column_a(w2)
      column_a = w2.box14_ui_wf_swf&.positive? ? w2.box14_ui_wf_swf : w2.box14_ui_hc_wd
      column_a&.round || 0
    end

    def get_column_c(w2)
      w2.box14_fli&.round || 0
    end
  end
end