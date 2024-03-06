module SubmissionBuilder
  module Shared
    class ReturnW2 < SubmissionBuilder::Document
      def document
        w2 = @kwargs[:w2]
        intake_w2 = @kwargs[:intake_w2]
        xml_node = Nokogiri::XML(w2.node.to_xml)
        if intake_w2.present?
          xml_node.at(:W2StateLocalTaxGrp).inner_html = intake_w2.state_tax_group_xml_node
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
