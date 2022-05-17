class AdditionalDependentsPdf
  include PdfHelper

  def source_pdf_name
    "tax_documents/additional_dependents"
  end

  def initialize(submission)
    # For some PDF fields, use values from the database b/c the XML values are truncated or missing.
    @xml_document = SubmissionBuilder::Ty2021::Documents::Irs1040.new(submission).document
  end

  def hash_for_pdf
    answers = {}
    dependent_nodes = @xml_document.search("DependentDetail")
    answers.merge!(dependents_info(dependent_nodes[4..])) if dependent_nodes.length > 4
    answers
  end

  private

  def dependents_info(dependent_nodes)
    answers = {}
    dependent_nodes.each_with_index do |dependent, index|
      answers["DependentNameRow#{index + 1}"] = [dependent.at("DependentFirstNm").text, dependent.at("DependentLastNm").text].join(" ")
      answers["TINRow#{index + 1}"] = dependent.at("DependentSSN").text
      answers["RelationshipRow#{index + 1}"] = dependent.at("DependentRelationshipCd").text
      answers["CTCRow#{index + 1}"] = xml_check_to_bool(dependent.at("EligibleForChildTaxCreditInd")) ? "Yes" : nil
      answers["OTCRow#{index + 1}"] = xml_check_to_bool(dependent.at("EligibleForODCInd")) ? "Yes" : nil
    end
    answers
  end

  def xml_check_to_bool(node)
    node&.text == "X"
  end
end
