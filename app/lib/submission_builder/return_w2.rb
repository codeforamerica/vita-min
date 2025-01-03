module SubmissionBuilder
  class ReturnW2 < SubmissionBuilder::Document
    def document
      w2 = @kwargs[:w2]
      @intake_w2 = @kwargs[:intake_w2]
      @xml_node = Nokogiri::XML(w2.node.to_xml)

      if @intake_w2.present?
        state_local_tax_grp_node = @xml_node.at(:W2StateLocalTaxGrp)
        state_tax_group_xml = Nokogiri::XML(@intake_w2.state_tax_group_xml_node.to_s, &:noblanks).to_xhtml(indent: 2)
        if state_tax_group_xml.present?
          state_local_tax_grp_node.inner_html = state_tax_group_xml
        else
          state_local_tax_grp_node.remove
        end

        node_after_box_14_codes = state_local_tax_grp_node || @xml_node.at(:StandardOrNonStandardCd)
        state_code = @intake_w2.state_file_intake.state_code
        box14_codes = StateFile::StateInformationService.w2_supported_box14_codes(state_code)
        @xml_node.xpath("//OtherDeductionsBenefitsGrp[Desc='UIHCWD']").remove
        box14_codes.each do |code|
          add_box_14_node(code, node_after_box_14_codes)
        end
      end
        
      @xml_node
    end

    def add_box_14_node(code, node_after_box_14_codes)
      field_name = "box14_#{code.downcase}".to_sym
      field_as_desc = code.delete '_'

      value = if field_name == :box14_ui_wf_swf
        @intake_w2.get_box14_ui_overwrite
      else
        @intake_w2[field_name]
      end

      return if !value.present? || !value.positive?

      existing_xml_node = @xml_node.at_xpath("//OtherDeductionsBenefitsGrp[Desc='#{field_as_desc}']")
      if existing_xml_node
        existing_xml_node.at('Amt').content = value.round.to_s
      else
        new_xml_node = Nokogiri::XML::Node.new('OtherDeductionsBenefitsGrp', @xml_node)

        desc_node = Nokogiri::XML::Node.new('Desc', @xml_node)
        desc_node.content = field_as_desc
        amt_node = Nokogiri::XML::Node.new('Amt', @xml_node)
        amt_node.content = value.round.to_s

        new_xml_node.add_child(desc_node)
        new_xml_node.add_child(amt_node)

        node_after_box_14_codes.add_previous_sibling(new_xml_node)
      end
    end
  end
end
