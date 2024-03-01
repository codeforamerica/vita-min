module StateFile
  module Questions
    class NyW2Controller < AuthenticatedQuestionsController
      def self.show?(intake)
        invalid_w2s(intake).any?
      end

      def self.invalid_w2s(intake)
        intake.direct_file_data.w2s.filter { |w2| invalid_w2?(intake, w2) }
      end

      private

      def self.invalid_w2?(intake, w2)
        return true if w2.StateWagesAmt == 0
        if intake.nyc_residency_full_year?
          return true if w2.LocalWagesAndTipsAmt == 0 || w2.LocalityNm.blank?
        end
        if w2.LocalityNm.blank?
          return true if w2.LocalWagesAndTipsAmt != 0 || w2.LocalIncomeTaxAmt != 0
        end
        return true if w2.LocalIncomeTaxAmt != 0 && w2.LocalWagesAndTipsAmt == 0
        return true if w2.StateIncomeTaxAmt != 0 && w2.StateWagesAmt == 0
        return true if w2.StateWagesAmt != 0 && w2.EmployerStateIdNum.blank?
        return true if w2.LocalityNm.present? && !StateFileNyIntake::LOCALITIES.include?(w2.LocalityNm)

        false
      end
    end
  end
end
