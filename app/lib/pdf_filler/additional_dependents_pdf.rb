module PdfFiller
  class AdditionalDependentsPdf
    include PdfHelper
    attr_accessor :start_node

    def source_pdf_name
      "tax_documents/additional_dependents"
    end

    def initialize(submission, start_node: 4)
      # For some PDF fields, use values from the database b/c the XML values are truncated or missing.
      @xml_document = SubmissionBuilder::Ty2021::Documents::Irs1040.new(submission).document
      @start_node = start_node
    end

    def hash_for_pdf
      answers = {}
      dependent_nodes = @xml_document.search("DependentDetail")
      answers.merge!(dependents_info(dependent_nodes[start_node..])) if dependent_nodes.length > start_node
      answers
    end

    private

    def dependents_info(dependent_nodes)
      answers = {}
      dependent_nodes.each_with_index do |dependent, index|
        answers["DependentNameRow#{index + 1}"] = [dependent.at("DependentFirstNm").text, dependent.at("DependentLastNm").text].join(" ")
        answers["TINRow#{index + 1}"] = dependent.at("DependentSSN").text
        answers["RelationshipRow#{index + 1}"] = dependent.at("DependentRelationshipCd").text
        answers["CTCRow#{index + 1}"] = xml_value_to_bool(dependent.at("EligibleForChildTaxCreditInd"), "CheckboxType") ? "Yes" : nil
        answers["ODCRow#{index + 1}"] = xml_value_to_bool(dependent.at("EligibleForODCInd"), "CheckboxType") ? "Yes" : nil
      end
      answers
    end
  end
end
