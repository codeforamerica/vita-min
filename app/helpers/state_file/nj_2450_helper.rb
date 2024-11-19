module StateFile
  module Nj2450Helper
    def line_name(line, primary_or_spouse)
      return :"#{line}_SPOUSE" if primary_or_spouse == :spouse
      :"#{line}_PRIMARY"
    end

    def get_persons_w2s(intake, ssn)
      intake.state_file_w2s.all&.select { |w2| w2.employee_ssn == ssn }
    end
  end
end