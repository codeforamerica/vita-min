require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::ScheduleEic, required_schema: "federal" do
  let(:submission) { create :efile_submission, :ctc, tax_year: 2021 }

  before do
    # create a fourth dependent, first three are from the intake factory
    create :dependent, intake: submission.intake

    # create a fifth dependent who is qualifying but won't be included because only 3 are allowed in the xml
    create :dependent, intake: submission.intake

    submission.intake.update(exceeded_investment_income_limit: "no", primary_tin_type: "ssn")
    dependent1 = submission.intake.dependents[0]
    dependent1_attrs = attributes_for(
      :qualifying_child,
      first_name: "Keeley Elizabeth Aurora",
      last_name: "Kiwi-Cucumbersteiningham",
      birth_date: 21.years.ago,
      relationship: "daughter",
      ssn: "123001234",
      ip_pin: "123456",
      full_time_student: "yes",
      months_in_home: 10
    )
    dependent1.update(dependent1_attrs)
    dependent2 = submission.intake.dependents.second
    dependent2_attrs = attributes_for(
      :qualifying_child,
      first_name: "Karen",
      last_name: "Kiwi",
      birth_date: 11.years.ago,
      relationship: "son",
      ssn: "123001235",
      ip_pin: "123456",
      permanently_totally_disabled: "yes",
      months_in_home: 8
    )
    dependent2.update(dependent2_attrs)
    dependent3 = submission.intake.dependents.third
    dependent3_attrs = attributes_for(
      :qualifying_relative,
      first_name: "Kelly",
      birth_date: Date.new(1960, 1, 1),
      relationship: "parent",
      ssn: "123001236"
    )
    dependent3.update(dependent3_attrs)
    dependent4 = submission.intake.dependents[3]
    dependent4_attrs = attributes_for(
      :qualifying_child,
      first_name: "Kevin",
      birth_date: 22.years.ago,
      permanently_totally_disabled: "yes",
      relationship: "son",
      ssn: "123001237"
    )
    dependent4.update(dependent4_attrs)
    dependent5 = submission.intake.dependents[4]
    dependent5_attrs = attributes_for(
      :qualifying_child,
      first_name: "Kevin the second",
      birth_date: 10.years.ago,
      permanently_totally_disabled: "yes",
      relationship: "son",
      ssn: "123001238"
    )
    dependent5.update(dependent5_attrs)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent1)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent2)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent3)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent4)
    EfileSubmissionDependent.create_qualifying_dependent(submission, dependent5)
    submission.reload
  end

  it "includes the correct nodes in the XML" do
    xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
    dependent_nodes = xml.search("QualifyingChildInformation")
    expect(dependent_nodes.length).to eq 3
    # First dependent
    expect(dependent_nodes[0].at("QualifyingChildNameControlTxt").text).to eq "KIWI"
    expect(dependent_nodes[0].at("PersonFirstNm").text).to eq "Keeley Elizabeth Aur"
    expect(dependent_nodes[0].at("PersonLastNm").text).to eq "Kiwi-Cucumbersteinin"
    expect(dependent_nodes[0].at("IdentityProtectionPIN").text).to eq "123456"
    expect(dependent_nodes[0].at("QualifyingChildSSN").text).to eq "123001234"
    expect(dependent_nodes[0].at("ChildBirthYr").text).to eq submission.intake.dependents.first.birth_date.year.to_s
    expect(dependent_nodes[0].at("ChildIsAStudentUnder24Ind").text).to eq "false"
    expect(dependent_nodes[0].at("ChildPermanentlyDisabledInd").text).to eq "false"
    expect(dependent_nodes[0].at("ChildRelationshipCd").text).to eq "DAUGHTER"
    expect(dependent_nodes[0].at("MonthsChildLivedWithYouCnt").text).to eq "10"
    # Second dependent
    expect(dependent_nodes[1].at("QualifyingChildNameControlTxt").text).to eq "KIWI"
    expect(dependent_nodes[1].at("PersonFirstNm").text).to eq "Karen"
    expect(dependent_nodes[1].at("PersonLastNm").text).to eq "Kiwi"
    expect(dependent_nodes[1].at("IdentityProtectionPIN").text).to eq "123456"
    expect(dependent_nodes[1].at("QualifyingChildSSN").text).to eq "123001235"
    expect(dependent_nodes[1].at("ChildBirthYr").text).to eq submission.intake.dependents.second.birth_date.year.to_s
    expect(dependent_nodes[1].at("ChildIsAStudentUnder24Ind").text).to eq "false"
    expect(dependent_nodes[1].at("ChildPermanentlyDisabledInd").text).to eq "true"
    expect(dependent_nodes[1].at("ChildRelationshipCd").text).to eq "SON"
    expect(dependent_nodes[1].at("MonthsChildLivedWithYouCnt").text).to eq "08"
    # Third dependent
    expect(dependent_nodes[2].at("PersonFirstNm").text).to eq "Kevin"
    expect(dependent_nodes[2].at("ChildIsAStudentUnder24Ind").text).to eq "false"
    expect(dependent_nodes[2].at("ChildPermanentlyDisabledInd").text).to eq "true"
  end

  context "checkboxes 4a and 4b" do
    context "when checkbox 4a is no" do
      before do
        allow_any_instance_of(EfileSubmissionDependent).to receive(:schedule_eic_4a?).and_return false
        allow_any_instance_of(EfileSubmissionDependent).to receive(:schedule_eic_4b?).and_return true
      end

      it "checks 4b as yes or no" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        dependent_nodes = xml.search("QualifyingChildInformation")

        expect(dependent_nodes[0].at("ChildIsAStudentUnder24Ind").text).to eq "false"
        expect(dependent_nodes[0].at("ChildPermanentlyDisabledInd").text).to eq "true"
      end
    end

    context "when checkbox 4a is yes" do
      before do
        allow_any_instance_of(EfileSubmissionDependent).to receive(:schedule_eic_4a?).and_return true
      end

      it "does not check 4b at all" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        dependent_nodes = xml.search("QualifyingChildInformation")

        expect(dependent_nodes[0].at("ChildIsAStudentUnder24Ind").text).to eq "true"
        expect(dependent_nodes[0].at("ChildPermanentlyDisabledInd")).to be_nil
      end
    end
  end

  it "conforms to the eFileAttachments schema 2021v5.2" do
    instance = described_class.new(submission)
    expect(instance.schema_version).to eq "2021v5.2"

    expect(described_class.build(submission)).to be_valid
  end

  context "with no IP pin" do
    before do
      submission.intake.dependents.first.update(ip_pin: nil)
    end

    it "conforms to the eFileAttachments schema 2021v5.2" do
      instance = described_class.new(submission)
      expect(instance.schema_version).to eq "2021v5.2"

      expect(described_class.build(submission)).to be_valid
    end
  end
end
