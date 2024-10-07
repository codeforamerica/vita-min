module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        module Documents
          class NjW2 < SubmissionBuilder::Document
            def document
              w2 = @kwargs[:w2]
              intake_w2 = @kwargs[:intake_w2]
              xml_node = Nokogiri::XML(w2.node.to_xml)
              xml_node.at("IRSW2")["documentName"] = "NJW2"
              xml_node.at("IRSW2").name = "NJW2"

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
                locality_nm.name = "NameOfLocality"
              end

              xml_node.at("EmployerNameControlTxt").name = "EmployerNameControl"
              xml_node.at("ControlNum").name = "ControlNumber" if xml_node.at("ControlNum").present?
              xml_node.at("EmployeeNm").name = "EmployeeName"
              xml_node.at("PriorUSERRAContributionYr").name = "PriorYearUserraContribution" if xml_node.at("PriorUSERRAContributionYr").present?
              xml_node.at("OtherDeductionsBenefitsGrp").name = "OtherDeductsBenefits"
              xml_node.at("EmployerStateIdNum").name = "EmployersStateIdNumber"

              xml_node.at("AgentForEmployerInd").remove if xml_node.at("AgentForEmployerInd").present?
              xml_node.at("W2SecurityInformation").remove if xml_node.at("W2SecurityInformation").present?

              xml_node
            end
          end
        end
      end
    end
  end
end
