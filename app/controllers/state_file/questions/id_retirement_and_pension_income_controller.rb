module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && !intake.filing_status_mfs? &&
          has_eligible_1099rs?(intake)
      end

      def self.has_eligible_1099rs?(intake)
        intake.state_file1099_rs.any? do |form1099r|
          form1099r.taxable_amount&.to_f&.positive? && person_qualifies?(form1099r, intake)
        end
      end

      def self.person_qualifies?(form1099r, intake)
        primary_tin = intake.primary.ssn
        spouse_tin = intake.spouse&.ssn

        case form1099r.recipient_ssn
        when primary_tin
          intake.primary_disabled_yes? || intake.primary_senior?
        when spouse_tin
          intake.spouse_disabled_yes? || intake.spouse_senior?
        else
          false
        end
      end

      private

      def person_qualifies?(form1099r)
        self.class.person_qualifies?(form1099r, current_intake)
      end

      def eligible_1099rs
        @eligible_1099rs ||= current_intake.state_file1099_rs.select do |form1099r|
          form1099r.taxable_amount&.to_f&.positive? && person_qualifies?(form1099r)
        end
      end

      def num_items
        eligible_1099rs.count
      end

      def load_item(index)
        @state_file_1099r = eligible_1099rs[index]
        render "public_pages/page_not_found", status: 404 if @state_file_1099r.nil?
      end

      def review_all_items_before_returning_to_review
        true
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end