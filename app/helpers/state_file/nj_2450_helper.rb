module StateFile
  module Nj2450Helper
    def line_name(line, primary_or_spouse)
      return :"#{line}_SPOUSE" if primary_or_spouse == :spouse
      :"#{line}_PRIMARY"
    end
  end
end