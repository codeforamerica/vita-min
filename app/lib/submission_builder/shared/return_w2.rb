module SubmissionBuilder
  module Shared
    class ReturnW2 < SubmissionBuilder::Document

      def document
        w2 = @kwargs[:w2]
        intake_w2 = @kwargs[:intake_w2]
        xml_node = Nokogiri::XML(w2.node.to_xml)

        if intake_w2
          ["EmployerStateIdNum", "LocalIncomeTaxAmt", "LocalWagesAndTipsAmt", "LocalityNm", "StateIncomeTaxAmt", "StateWagesAmt"].each do |attr|
            value = intake_w2.send(attr.underscore)
            value = value.round if value.is_a?(BigDecimal)
            xml_node.at(attr).content = value
          end
        end

        xml_node
      end
    end
  end
end
