module SubmissionBuilder
  module Shared
    class ReturnW2 < SubmissionBuilder::Document
      def document
        w2 = @kwargs[:w2]
        intake_w2 = @kwargs[:intake_w2]
        xml_node = Nokogiri::XML(w2.node.to_xml)
        w2 = DirectFileData::DfW2.new(xml_node)
        # if w2.EmployerName.include?("Skip The Whole Page Diner")
        #   binding.pry
        # end
        if intake_w2.present?
          # w2.create_or_destroy_df_xml_node(:W2StateTaxGrp, nil)

          # w2.create_or_destroy_df_xml_node(:StateAbbreviationCd, 1, "MedicareTaxWithheldAmt")
          # w2.create_or_destroy_df_xml_node(:EmployerStateIdNum, 1)
          # w2.create_or_destroy_df_xml_node(:StateWagesAmt, 1)
          # w2.create_or_destroy_df_xml_node(:StateIncomeTaxAmt, 1)
          # w2.create_or_destroy_df_xml_node(:LocalWagesAndTipsAmt, 1)
          # w2.create_or_destroy_df_xml_node(:LocalIncomeTaxAmt, 1)
          # w2.create_or_destroy_df_xml_node(:LocalityNm, 1)

          update_xml(w2, :StateAbbreviationCd, "NY")
          update_xml(w2, :EmployerStateIdNum, intake_w2.employer_state_id_num)
          update_xml(w2, :StateWagesAmt, intake_w2.state_wages_amt)
          update_xml(w2, :StateIncomeTaxAmt, intake_w2.state_income_tax_amt)
          update_xml(w2, :LocalWagesAndTipsAmt, intake_w2.local_wages_and_tips_amt)
          update_xml(w2, :LocalIncomeTaxAmt, intake_w2.local_income_tax_amt)
          update_xml(w2, :LocalityNm, intake_w2.locality_nm)
        end
        xml_node
      end

      private

      def update_xml(w2, attr, value, prev = nil)
        if value == 0
          value = nil
        end
        # w2.create_or_destroy_df_xml_node(attr, value, prev)
        w2.send("#{attr}=", value)
      end
    end
  end
end
