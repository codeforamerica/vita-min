module SubmissionBuilder
  class ReturnW2 < SubmissionBuilder::Document
    def document
      w2 = @kwargs[:w2]
      intake_w2 = @kwargs[:intake_w2]
      xml_node = Nokogiri::XML(w2.node.to_xml)
      if intake_w2.present?
        state_local_tax_grp_node = xml_node.at(:W2StateLocalTaxGrp)
        state_tax_group_xml = Nokogiri::XML(intake_w2.state_tax_group_xml_node.to_s, &:noblanks).to_xhtml(indent: 2)
        if state_tax_group_xml.present?
          state_local_tax_grp_node.inner_html = state_tax_group_xml
        else
          state_local_tax_grp_node.remove
        end

        if intake_w2.box14_stpickup.present? && intake_w2.box14_stpickup.positive?
          existing_stpickup = xml_node.at_xpath("//OtherDeductionsBenefitsGrp[Desc='STPICKUP']")
          if existing_stpickup
            existing_stpickup.at('Amt').content = intake_w2.box14_stpickup.round.to_s
          else
            stpickup_node = Nokogiri::XML::Node.new('OtherDeductionsBenefitsGrp', xml_node)

            desc_node = Nokogiri::XML::Node.new('Desc', xml_node)
            desc_node.content = 'STPICKUP'
            amt_node = Nokogiri::XML::Node.new('Amt', xml_node)
            amt_node.content = intake_w2.box14_stpickup.round.to_s

            stpickup_node.add_child(desc_node)
            stpickup_node.add_child(amt_node)

            if state_local_tax_grp_node.present?
              state_local_tax_grp_node.add_previous_sibling(stpickup_node)
            else
              xml_node.at(:StandardOrNonStandardCd).add_previous_sibling(stpickup_node)
            end
          end
        end
      end
        
      xml_node
    end
  end
end
