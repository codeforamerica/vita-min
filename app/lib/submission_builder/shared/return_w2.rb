module SubmissionBuilder
  module Shared
    class ReturnW2 < SubmissionBuilder::Document
      def document
        w2 = @kwargs[:w2]
        intake_w2 = @kwargs[:intake_w2]
        xml_node = Nokogiri::XML(w2.node.to_xml)
        if intake_w2.present?
          state_local_tax_grp_node = xml_node.at(:W2StateLocalTaxGrp)
          state_tax_group_xml = intake_w2.state_tax_group_xml_node
          if state_tax_group_xml.present?
            state_local_tax_grp_node.inner_html = state_tax_group_xml
          else
            state_local_tax_grp_node.remove
          end
        end
        locality_nm = xml_node.at(:LocalityNm)
        if locality_nm.present?
          locality_nm.inner_html = locality_nm.inner_html.upcase
        end
        xml_node
      end
    end
  end
end
