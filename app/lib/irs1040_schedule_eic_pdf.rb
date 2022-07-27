class Irs1040ScheduleEicPdf
  include PdfHelper

  def source_pdf_name
    "tax_documents/f1040sei-TY2021"
  end

  def initialize(submission)
    @xml_document = SubmissionBuilder::Ty2021::Documents::ScheduleEic.new(submission).document
    @intake = submission.intake
  end

  def hash_for_pdf
    answers = {
      FullPrimaryName: @intake.primary_full_name,
      PrimarySSN: @intake.primary_ssn
    }
    dependent_nodes = @xml_document.search("QualifyingChildInformation")
    answers.merge!(dependents_info(dependent_nodes[0..]))
    answers
  end

  private

  def dependents_info(dependent_nodes)
    answers = {}
    dependent_nodes.each_with_index do |dependent, index|
      answers["ChildFirstAndLastName#{index + 1}"] = dependent.at("ChildFirstAndLastName").text
        answers["QualifyingChildSSN#{index + 1}"] = dependent.at("QualifyingChildSSN").text
        answers["ChildBirthYr#{index + 1}[0]"] = dependent.at("ChildBirthYr").text[0]
        answers["ChildBirthY#{index + 1}1[1]"] = dependent.at("ChildBirthYr").text[1]
        answers["ChildBirthYr#{index + 1}[2]"] = dependent.at("ChildBirthYr").text[2]
        answers["ChildBirthYr#{index + 1}[3]"] = dependent.at("ChildBirthYr").text[3]
        answers["ChildIsAStudentUnder24IndYes#{index + 1}"] =  xml_check_to_bool(dependent.at("ChildIsAStudentUnder24Ind")) ? "Yes" : nil
        answers["ChildIsAStudentUnder24IndNo#{index + 1}"] = !xml_check_to_bool(dependent.at("ChildIsAStudentUnder24Ind")) ? "Yes" : nil
        answers["ChildPermanentlyDisabledIndYes#{index + 1}"] = xml_check_to_bool(dependent.at("ChildPermanentlyDisabledInd")) ? "Yes" : nil
        answers["ChildPermanentlyDisabledIndNo#{index + 1}"] = !xml_check_to_bool(dependent.at("ChildPermanentlyDisabledInd")) ? "Yes" : nil
        answers["ChildRelationshipCd#{index + 1}"] = dependent.at("ChildRelationshipCd").text
        answers["MonthsChildLivedWithYouCnt#{index + 1}"] = dependent.at("MonthsChildLivedWithYouCnt").text
    end
    answers
  end
end