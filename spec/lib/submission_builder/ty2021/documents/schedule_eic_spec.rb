require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::ScheduleEic do
  let(:submission) { create :efile_submission, :ctc, tax_year: 2021 }
  before do
    dependent = submission.intake.dependents.first
    dependent_attrs = attributes_for(:qualifying_child, first_name: "Keeley Elizabeth Aurora", last_name: "Kiwi-Cucumbersteiningham", birth_date: Date.new(2020, 1, 1), relationship: "daughter", ssn: "123001234", ip_pin: "123456", full_time_student: "yes")
    dependent.update(dependent_attrs)
    dependent2 = submission.intake.dependents.second
    dependent2_attrs = attributes_for(:qualifying_child, birth_date: Date.new(2010, 1, 1), relationship: "son", ssn: "123001235", ip_pin: "123456", permanently_totally_disabled: "yes")
    dependent2.update(dependent2_attrs)
    dependent3 = submission.intake.dependents.third
    dependent3_attrs = attributes_for(:qualifying_relative, first_name: "Kelly", birth_date: Date.new(1960, 1, 1), relationship: "parent", ssn: "123001236")
    dependent3.update(dependent3_attrs)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent2)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent3)
    submission.reload
  end

  it "includes the correct nodes in the XML" do
    xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
    dependent_nodes = xml.search("QualifyingChildInformation")
    expect(dependent_nodes.length).to eq 2
    # First dependent
    expect(dependent_nodes[0].at("QualifyingChildNameControlTxt").text).to eq "KIWI"
    expect(dependent_nodes[0].at("PersonFirstNm").text).to eq "Keeley Elizabeth Aur"
    expect(dependent_nodes[0].at("PersonLastNm").text).to eq "Kiwi-Cucumbersteinin"
    expect(dependent_nodes[0].at("IdentityProtectionPIN").text).to eq "123456"
    expect(dependent_nodes[0].at("QualifyingChildSSN").text).to eq "123001234"
    expect(dependent_nodes[0].at("ChildBirthYr").text).to eq "2020"
    expect(dependent_nodes[0].at("ChildIsAStudentUnder24Ind").text).to eq "true"
    expect(dependent_nodes[0].at("ChildPermanentlyDisabledInd").text).to eq "false"
    expect(dependent_nodes[0].at("ChildRelationshipCd").text).to eq "DAUGHTER"
    expect(dependent_nodes[0].at("MonthsChildLivedWithYouCnt").text).to eq "07"
    # Second dependent
    expect(dependent_nodes[1].at("QualifyingChildNameControlTxt").text).to eq "KIWI"
    expect(dependent_nodes[1].at("PersonFirstNm").text).to eq "Kara"
    expect(dependent_nodes[1].at("PersonLastNm").text).to eq "Kiwi"
    expect(dependent_nodes[1].at("IdentityProtectionPIN").text).to eq "123456"
    expect(dependent_nodes[1].at("QualifyingChildSSN").text).to eq "123001235"
    expect(dependent_nodes[1].at("ChildBirthYr").text).to eq "2010"
    expect(dependent_nodes[1].at("ChildIsAStudentUnder24Ind").text).to eq "false"
    expect(dependent_nodes[1].at("ChildPermanentlyDisabledInd").text).to eq "true"
    expect(dependent_nodes[1].at("ChildRelationshipCd").text).to eq "SON"
    expect(dependent_nodes[1].at("MonthsChildLivedWithYouCnt").text).to eq "07"
  end

  it "conforms to the eFileAttachments schema 2021v5.2" do
    instance = described_class.new(submission)
    expect(instance.schema_version).to eq "2021v5.2"

    expect(described_class.build(submission)).to be_valid
  end
end