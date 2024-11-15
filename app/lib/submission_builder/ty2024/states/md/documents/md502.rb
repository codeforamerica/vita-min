class SubmissionBuilder::Ty2024::States::Md::Documents::Md502 < SubmissionBuilder::Document
  include SubmissionBuilder::FormattingMethods

  # from MDIndividualeFileTypes.xsd
  FILING_STATUS_OPTIONS = {
    single: "Single",
    married_filing_jointly: 'Joint',
    married_filing_separately: 'MarriedFilingSeparately',
    head_of_household: 'HeadOfHousehold',
    qualifying_widow: 'QualifyingWidow',
    dependent: 'DependentTaxpayer'
  }.freeze

  COUNTY_ABBREVIATIONS = {
    "Allegany" => "AL",
    "Anne Arundel" => "AA",
    "Baltimore County" => "BL",
    "Baltimore City" => "BC",
    "Calvert" => "CV",
    "Caroline" => "CL",
    "Carroll" => "CR",
    "Cecil" => "CC",
    "Charles" => "CH",
    "Dorchester" => "DR",
    "Frederick" => "FR",
    "Garrett" => "GR",
    "Harford" => "HR",
    "Howard" => "HW",
    "Kent" => "KN",
    "Montgomery" => "MG",
    "Prince George's" => "PG",
    "Queen Anne's" => "QA",
    "St. Mary's" => "SM",
    "Somerset" => "SS",
    "Talbot" => "TB",
    "Washington" => "WH",
    "Wicomico" => "WC",
    "Worcester" => "WR"
  }.freeze

  def document
    build_xml_doc("Form502", documentId: "Form502") do |xml|
      xml.MarylandSubdivisionCode @intake.subdivision_code
      unless @intake.political_subdivision&.end_with?("- unincorporated")
        xml.CityTownOrTaxingArea @intake.political_subdivision
      end
      xml.MarylandAddress do
        if @intake.confirmed_permanent_address_yes?
          xml.AddressLine1Txt sanitize_for_xml(@intake.direct_file_data.mailing_street, 35)
          xml.AddressLine2Txt sanitize_for_xml(@intake.direct_file_data.mailing_apartment, 35)
          xml.CityNm sanitize_for_xml(@intake.direct_file_data.mailing_city, 22)
          xml.StateAbbreviationCd @intake.state_code.upcase
          xml.ZIPCd @intake.direct_file_data.mailing_zip
        elsif @intake.confirmed_permanent_address_no?
          xml.AddressLine1Txt sanitize_for_xml(@intake.permanent_street, 35)
          xml.AddressLine2Txt sanitize_for_xml(@intake.permanent_apartment, 35)
          xml.CityNm sanitize_for_xml(@intake.permanent_city, 22)
          xml.StateAbbreviationCd @intake.state_code.upcase
          xml.ZIPCd @intake.permanent_zip
        end
      end
      xml.MarylandCounty county_abbreviation
      if @intake.direct_file_data.claimed_as_dependent?
        xml.FilingStatus do
          xml.DependentTaxpayer "X"
        end
      elsif @intake.filing_status == :married_filing_separately
        xml.FilingStatus do
          xml.MarriedFilingSeparately "X", spouseSSN: @intake.direct_file_data.spouse_ssn
        end
      else
        xml.FilingStatus do
          xml.send(filing_status, "X")
        end
      end
      if has_exemptions?
        xml.Exemptions do
          xml.Primary do
            add_element_if_present(xml, "Standard", :MD502_LINE_A_PRIMARY)
            add_element_if_present(xml, "Over65", :MD502_LINE_B_PRIMARY_SENIOR)
            add_element_if_present(xml, "Blind", :MD502_LINE_B_PRIMARY_BLIND)
          end
          if @intake.filing_status_mfj? || @intake.filing_status_qw? # qw?
            xml.Spouse do
              add_element_if_present(xml, "Standard", :MD502_LINE_A_SPOUSE)
              add_element_if_present(xml, "Over65", :MD502_LINE_B_SPOUSE_SENIOR)
              add_element_if_present(xml, "Blind", :MD502_LINE_B_SPOUSE_BLIND)
            end
          end
          xml.Standard do
            xml.Count calculated_fields.fetch(:MD502_LINE_A_COUNT)
            xml.Amount calculated_fields.fetch(:MD502_LINE_A_AMOUNT)
          end
          xml.Additional do
            xml.Count calculated_fields.fetch(:MD502_LINE_B_COUNT)
            xml.Amount calculated_fields.fetch(:MD502_LINE_B_AMOUNT)
          end
          if has_dependent_exemption?
            xml.Dependents do
              xml.Count calculated_fields.fetch(:MD502_LINE_C_COUNT)
              xml.Amount calculated_fields.fetch(:MD502_LINE_C_AMOUNT)
            end
          end
          xml.Total do
            xml.Count calculated_fields.fetch(:MD502_LINE_D_COUNT_TOTAL)
            xml.Amount calculated_fields.fetch(:MD502_LINE_D_AMOUNT_TOTAL)
          end
        end
      end
      income_section(xml)
      xml.Additions do
        xml.StateRetirementPickup calculated_fields.fetch(:MD502_LINE_3)
        xml.Total calculated_fields.fetch(:MD502_LINE_6)
        xml.FedAGIAndStateAdditions calculated_fields.fetch(:MD502_LINE_7)
      end
      xml.Subtractions do
        xml.ChildAndDependentCareExpenses @direct_file_data.total_qualifying_dependent_care_expenses
        xml.SocialSecurityRailRoadBenefits @direct_file_data.fed_taxable_ssb
        xml.Other calculated_fields.fetch(:MD502_LINE_13)
      end
      xml.Deduction do
        xml.Method calculated_fields.fetch(:MD502_DEDUCTION_METHOD)
        xml.Amount calculated_fields.fetch(:MD502_LINE_17) if @deduction_method_is_standard
      end
      if @deduction_method_is_standard
        xml.NetIncome calculated_fields.fetch(:MD502_LINE_18)
        xml.ExemptionAmount calculated_fields.fetch(:MD502_LINE_19)
      end
      if has_state_tax_computation?
        xml.StateTaxComputation do
          xml.TaxableNetIncome calculated_fields.fetch(:MD502_LINE_20) if @deduction_method_is_standard
          add_element_if_present(xml, "StateIncomeTax", :MD502_LINE_21)
          add_element_if_present(xml, "EarnedIncomeCredit", :MD502_LINE_22)
          add_element_if_present(xml, "MDEICWithQualChildInd", :MD502_LINE_22B)
        end
      end
      xml.LocalTaxComputation do
        add_element_if_present(xml, "LocalTaxRate", :MD502_LINE_28_LOCAL_TAX_RATE) unless @intake.residence_county == "Anne Arundel"
        add_element_if_present(xml, "LocalIncomeTax", :MD502_LINE_28_LOCAL_TAX_AMOUNT)
        add_element_if_present(xml, "EarnedIncomeCredit", :MD502_LINE_29)
        add_element_if_present(xml,"TotalCredits", :MD502_LINE_32)
        add_element_if_present(xml,"LocalTaxAfterCredits", :MD502_LINE_33)
      end
      add_element_if_present(xml, "TotalStateAndLocalTax", :MD502_LINE_34)
      xml.TaxWithheld calculated_fields.fetch(:MD502_LINE_40)
      xml.DaytimePhoneNumber @direct_file_data.phone_number if @direct_file_data.phone_number.present?
    end
  end

  private

  def income_section(root_xml)
    root_xml.Income do |income|
      income.FederalAdjustedGrossIncome calculated_fields.fetch(:MD502_LINE_1)
      income.WagesSalariesAndTips calculated_fields.fetch(:MD502_LINE_1A)
      income.EarnedIncome calculated_fields.fetch(:MD502_LINE_1B)
      income.TaxablePensionsIRAsAnnuities calculated_fields.fetch(:MD502_LINE_1D)
      if calculated_fields.fetch(:MD502_LINE_1E)
        income.InvestmentIncomeIndicator "X"
      end
    end
  end

  def calculated_fields
    @md502_fields ||= @intake.tax_calculator.calculate
    @deduction_method_is_standard ||= @md502_fields.fetch(:MD502_DEDUCTION_METHOD) == "S"
    @md502_fields
  end

  def has_dependent_exemption?
    [
      :MD502_LINE_C_COUNT,
      :MD502_LINE_C_AMOUNT
    ].any? do |line|
      calculated_fields.fetch(line) > 0
    end
  end

  def has_exemptions?
    has_line_a_or_b_exemptions = [
      :MD502_LINE_A_COUNT,
      :MD502_LINE_B_COUNT
    ].any? do |line|
      calculated_fields.fetch(line) > 0
    end
    has_dependent_exemption? || has_line_a_or_b_exemptions
  end

  def has_state_tax_computation?
    @deduction_method_is_standard || calculated_fields.fetch(:MD502_LINE_22)&.positive?
  end

  def filing_status
    FILING_STATUS_OPTIONS[@intake.filing_status]
  end

  def county_abbreviation
    COUNTY_ABBREVIATIONS[@intake.residence_county]
  end

  def add_element_if_present(xml, tag, line_id)
    value = calculated_fields.fetch(line_id)
    xml.send(tag, value) if value.present?
  end
end
