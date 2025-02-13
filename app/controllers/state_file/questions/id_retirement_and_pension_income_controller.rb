module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) &&
          intake.state_file1099_rs.any? { |form1099r| form1099r.taxable_amount&.to_f&.positive? } &&
          !intake.filing_status_mfs?
      end

      def person_qualifies?(form1099r)
        if form1099r.recipient_ssn == current_intake.direct_file_json_data.primary_filer
          current_intake.primary_disabled_yes? || current_intake.primary_senior?
        elsif form1099r.recipient_ssn == current_intake.direct_file_json_data.spouse_filer
          current_intake.spouse_disabled_yes? || current_intake.spouse_senior?
        else
          false
        end
      end

      def num_items
        current_intake.state_file1099_rs.count { |form1099r|
          form1099r.taxable_amount&.to_f&.positive? &&
            person_qualifies?(form1099r)
        }
      end

      def load_item(index)
        eligible_1099rs = current_intake.state_file1099_rs.select { |form1099r|
          form1099r.taxable_amount&.to_f&.positive? &&
            person_qualifies?(form1099r)
        }
        @state_file_1099r = eligible_1099rs[index]

        if @state_file_1099r.nil?
          render "public_pages/page_not_found", status: 404
        end
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end