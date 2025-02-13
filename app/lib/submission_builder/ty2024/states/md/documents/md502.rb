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
      unless @intake.political_subdivision == "All Other Areas"
        xml.CityTownOrTaxingArea @intake.political_subdivision
      end
      xml.MarylandAddress do
        if @intake.confirmed_permanent_address_yes?
          extract_apartment_from_mailing_street(xml)
          xml.CityNm sanitize_for_xml(@intake.direct_file_data.mailing_city, 20)
          xml.StateAbbreviationCd @intake.direct_file_data.mailing_state.upcase
          xml.ZIPCd sanitize_zipcode(@intake.direct_file_data.mailing_zip)
        elsif @intake.confirmed_permanent_address_no?
          xml.AddressLine1Txt sanitize_for_xml(@intake.permanent_street, 30)
          xml.AddressLine2Txt sanitize_for_xml(@intake.permanent_apartment, 30) if @intake.permanent_apartment.present?
          xml.CityNm sanitize_for_xml(@intake.permanent_city, 20)
          xml.StateAbbreviationCd "MD"
          xml.ZIPCd sanitize_zipcode(@intake.permanent_zip)
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
      xml.Exemptions do
        if has_exemptions?
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
        end
        xml.Standard do
          xml.Count calculated_fields.fetch(:MD502_LINE_A_COUNT)
          xml.Amount calculated_fields.fetch(:MD502_LINE_A_AMOUNT)
        end
        if has_exemptions?
          xml.Additional do
            xml.Count calculated_fields.fetch(:MD502_LINE_B_COUNT)
            xml.Amount calculated_fields.fetch(:MD502_LINE_B_AMOUNT)
          end
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
      if has_healthcare_coverage_section?
        xml.MDHealthCareCoverage do
          if @intake.primary_did_not_have_health_insurance_yes?
            xml.PriWithoutHealthCoverageInd "X"
            xml.PriDOB date_type(@intake.primary_birth_date)
          end
          if @intake.spouse_did_not_have_health_insurance_yes?
            xml.SecWithoutHealthCoverageInd "X"
            xml.SecDOB date_type(@intake.spouse_birth_date)
          end
          if @intake.authorize_sharing_of_health_insurance_info_yes?
            xml.AuthorToShareInfoHealthExchInd "X"
            xml.TaxpayerEmailAddress email_from_intake_or_df
          end
        end
      end
      income_section(xml)
      xml.Additions do
        add_element_if_present(xml, "StateRetirementPickup", :MD502_LINE_3)
        add_element_if_present(xml, "Total", :MD502_LINE_6)
        add_element_if_present(xml, "FedAGIAndStateAdditions", :MD502_LINE_7)
      end
      xml.Subtractions do
        add_element_if_present(xml, "ChildAndDependentCareExpenses", :MD502_LINE_9)
        add_element_if_present(xml, "SocialSecurityRailRoadBenefits", :MD502_LINE_11)
        add_element_if_present(xml, "Other", :MD502_LINE_13)
        add_element_if_present(xml, "TwoIncome", :MD502_LINE_14)
        add_element_if_present(xml, "Total", :MD502_LINE_15)
        add_element_if_present(xml, "StateAdjustedGrossIncome", :MD502_LINE_16)
        if Flipper.enabled?(:show_retirement_ui)
          xml.PriPensionExclusionInd "X" if calculated_fields.fetch(:MD502R_LINE_11A).positive?
          xml.SecPensionExclusionInd "X" if calculated_fields.fetch(:MD502R_LINE_11B).positive?
          add_non_zero_value(xml, "PensionExclusions", :MD502_LINE_10A)
        end
      end
      xml.Deduction do
        xml.Method calculated_fields.fetch(:MD502_DEDUCTION_METHOD)
        add_element_if_present(xml, "Amount", :MD502_LINE_17) if @deduction_method_is_standard
      end
      if @deduction_method_is_standard
        add_element_if_present(xml, "NetIncome", :MD502_LINE_18)
      end
      add_element_if_present(xml, "ExemptionAmount", :MD502_LINE_19)
      if has_state_tax_computation?
        xml.StateTaxComputation do
          add_element_if_present(xml, "TaxableNetIncome", :MD502_LINE_20) if @deduction_method_is_standard
          add_element_if_present(xml, "StateIncomeTax", :MD502_LINE_21)
          add_element_if_present(xml, "EarnedIncomeCredit", :MD502_LINE_22)
          add_element_if_present(xml, "MDEICWithQualChildInd", :MD502_LINE_22B)
          add_element_if_present(xml, "PovertyLevelCredit", :MD502_LINE_23) if @deduction_method_is_standard
          add_element_if_present(xml, "IndividualTaxCredits", :MD502_LINE_24)
          add_element_if_present(xml, "TotalCredits", :MD502_LINE_26)
          add_element_if_present(xml, "StateTaxAfterCredits", :MD502_LINE_27) if @deduction_method_is_standard
        end
      end
      xml.LocalTaxComputation do
        add_element_if_present(xml, "LocalTaxRate", :MD502_LINE_28_LOCAL_TAX_RATE)
        add_element_if_present(xml, "LocalIncomeTax", :MD502_LINE_28_LOCAL_TAX_AMOUNT)
        add_element_if_present(xml, "EarnedIncomeCredit", :MD502_LINE_29)
        add_element_if_present(xml, "PovertyLevelCredit", :MD502_LINE_30)
        add_element_if_present(xml, "TotalCredits", :MD502_LINE_32)
        add_element_if_present(xml, "LocalTaxAfterCredits", :MD502_LINE_33)
      end
      add_element_if_present(xml, "TotalStateAndLocalTax", :MD502_LINE_34)
      add_element_if_present(xml, "TotalTaxAndContributions", :MD502_LINE_39)
      add_element_if_present(xml, "TaxWithheld", :MD502_LINE_40)
      add_element_if_present(xml, "RefundableEIC", :MD502_LINE_42)
      add_element_if_present(xml, "RefundableTaxCredits", :MD502_LINE_43)
      add_element_if_present(xml, "TotalPaymentsAndCredits", :MD502_LINE_44)
      add_element_if_present(xml, "BalanceDue", :MD502_LINE_45)
      add_element_if_present(xml, "Overpayment", :MD502_LINE_46)
      if calculated_fields.fetch(:MD502_LINE_48).positive?
        xml.AmountOverpayment do
          xml.ToBeRefunded calculated_fields.fetch(:MD502_LINE_48)
        end
      end
      add_element_if_present(xml, "TotalAmountDue", :MD502_LINE_50)
      xml.AuthToDirectDepositInd "X" if calculated_fields.fetch(:MD502_AUTHORIZE_DIRECT_DEPOSIT)
      if @intake.payment_or_deposit_type.to_sym == :direct_deposit && @intake.refund_or_owe_taxes_type == :refund
        xml.NameOnBankAccount do
          xml.FirstName sanitize_for_xml(@intake.account_holder_first_name, 16) if @intake.account_holder_first_name
          xml.MiddleInitial sanitize_for_xml(@intake.account_holder_middle_initial) if @intake.account_holder_middle_initial
          xml.LastName sanitize_for_xml(@intake.account_holder_last_name, 32) if @intake.account_holder_last_name
          xml.NameSuffix @intake.account_holder_suffix if @intake.account_holder_suffix
        end
        if @intake.has_joint_account_holder_yes?
          xml.NameOnBankAccount do
            xml.FirstName sanitize_for_xml(@intake.joint_account_holder_first_name, 16) if @intake.joint_account_holder_first_name
            xml.MiddleInitial sanitize_for_xml(@intake.joint_account_holder_middle_initial) if @intake.joint_account_holder_middle_initial
            xml.LastName sanitize_for_xml(@intake.joint_account_holder_last_name, 32) if @intake.joint_account_holder_last_name
            xml.NameSuffix @intake.joint_account_holder_suffix if @intake.joint_account_holder_suffix
          end
        end
      end
      xml.DaytimePhoneNumber @direct_file_data.phone_number if @direct_file_data.phone_number.present?
      xml.EmailAddress @intake.email_address if @intake.email_address.present?
    end
  end

  private

  def income_section(root_xml)
    root_xml.Income do |income|
      income.FederalAdjustedGrossIncome calculated_fields.fetch(:MD502_LINE_1)
      add_element_if_present(income, :WagesSalariesAndTips, :MD502_LINE_1A)
      add_element_if_present(income, :EarnedIncome, :MD502_LINE_1B)
      add_element_if_present(income, :TaxablePensionsIRAsAnnuities, :MD502_LINE_1D)
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

  def has_healthcare_coverage_section?
    @intake.primary_did_not_have_health_insurance_yes? ||
      @intake.spouse_did_not_have_health_insurance_yes? ||
      @intake.authorize_sharing_of_health_insurance_info_yes?
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
end
