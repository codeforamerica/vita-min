module SubmissionBuilder
  module Ty2024
    module States
      module Nj
        module Documents
          class NjW2 < SubmissionBuilder::ReturnW2
            def schema_file
              SchemaFileLoader.load_file("us_states", "unpacked", "NJIndividual2024V0.1", "NJCommon", "NJW2.xsd")
            end

            def document
              xml_node = super
              xml_node.at("IRSW2")["documentName"] = "NJW2"
              xml_node.at("IRSW2").name = "NJW2"

              xml_node.at("EmployerNameControlTxt").name = "EmployerNameControl"
              xml_node.at("ControlNum").name = "ControlNumber" if xml_node.at("ControlNum").present?
              xml_node.at("EmployeeNm").name = "EmployeeName" if xml_node.at("EmployeeNm").present?
              xml_node.at("PriorUSERRAContributionYr").name = "PriorYearUserraContribution" if xml_node.at("PriorUSERRAContributionYr").present?

              box_14_nodes = xml_node.css("OtherDeductionsBenefitsGrp")
              box_14_nodes.each do |box14_node|
                box14_node.name = "OtherDeductsBenefits"
              end

              xml_node.at("EmployerStateIdNum").name = "EmployersStateIdNumber" if xml_node.at("EmployerStateIdNum").present?
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
