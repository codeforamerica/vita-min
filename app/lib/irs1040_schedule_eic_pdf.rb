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
      FullPrimaryName: @intake.primary.first_and_last_name,
      PrimarySSN: @intake.primary.ssn
    }
    dependent_nodes = @xml_document.search("QualifyingChildInformation")
    answers.merge!(dependents_info(dependent_nodes))
  end

  private

  def dependents_info(dependent_nodes)
    answers = {}
    dependent_nodes.each_with_index do |dependent, index|
      answers["ChildFirstAndLastName#{index + 1}"] = "#{dependent.at("PersonFirstNm").text} #{dependent.at("PersonLastNm").text}"
        answers["QualifyingChildSSN#{index + 1}"] = dependent.at("QualifyingChildSSN").text
        answers["ChildBirthYr#{index + 1}[0]"] = dependent.at("ChildBirthYr").text[0]
        answers["ChildBirthYr#{index + 1}[1]"] = dependent.at("ChildBirthYr").text[1]
        answers["ChildBirthYr#{index + 1}[2]"] = dependent.at("ChildBirthYr").text[2]
        answers["ChildBirthYr#{index + 1}[3]"] = dependent.at("ChildBirthYr").text[3]
        bool = xml_bool_to_bool(dependent.at("ChildIsAStudentUnder24Ind"))
        answers["ChildIsAStudentUnder24IndYes#{index + 1}"] =  bool ? "Yes" : nil
        answers["ChildIsAStudentUnder24IndNo#{index + 1}"] = !bool ? "Yes" : nil
        bool = xml_bool_to_bool(dependent.at("ChildPermanentlyDisabledInd"))
        answers["ChildPermanentlyDisabledIndYes#{index + 1}"] = bool ? "Yes" : nil
        answers["ChildPermanentlyDisabledIndNo#{index + 1}"] = !bool ? "Yes" : nil
        answers["ChildRelationshipCd#{index + 1}"] = dependent.at("ChildRelationshipCd").text
        answers["MonthsChildLivedWithYouCnt#{index + 1}"] = dependent.at("MonthsChildLivedWithYouCnt").text
    end
    answers
  end
end
