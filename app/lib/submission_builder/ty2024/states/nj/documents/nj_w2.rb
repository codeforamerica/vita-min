module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        module Documents
          class NjW2 < SubmissionBuilder::ReturnW2
            def document
              xml_node = super

              xml_node.at("IRSW2")["documentName"] = "NJW2"
              xml_node.at("IRSW2").name = "NJW2"

              xml_node.at("EmployerNameControlTxt").name = "EmployerNameControl"
              xml_node.at("ControlNum").name = "ControlNumber" if xml_node.at("ControlNum").present?
              xml_node.at("EmployeeNm").name = "EmployeeName"
              xml_node.at("PriorUSERRAContributionYr").name = "PriorYearUserraContribution" if xml_node.at("PriorUSERRAContributionYr").present?
              xml_node.at("OtherDeductionsBenefitsGrp").name = "OtherDeductsBenefits"
              xml_node.at("EmployerStateIdNum").name = "EmployersStateIdNumber"
              xml_node.at("LocalityNm").name = "NameOfLocality" if xml_node.at("LocalityNm").present?

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
