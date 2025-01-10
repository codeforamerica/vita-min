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
          xml.ZIPCd @intake.direct_file_data.mailing_zip
        elsif @intake.confirmed_permanent_address_no?
          xml.AddressLine1Txt sanitize_for_xml(@intake.permanent_street, 30)
          xml.AddressLine2Txt sanitize_for_xml(@intake.permanent_apartment, 30) if @intake.permanent_apartment.present?
          xml.CityNm sanitize_for_xml(@intake.permanent_city, 20)
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
        add_positive_amount_nn_value(xml, :StateRetirementPickup, :MD502_LINE_3, 15)
        add_positive_amount_nn_value(xml, :Total, :MD502_LINE_6, 15)
        add_integer_amount_if_present(xml, :FedAGIAndStateAdditions, :MD502_LINE_7, 15)
      end
      xml.Subtractions do
        add_positive_amount_nn_value(xml, :ChildAndDependentCareExpenses, :MD502_LINE_9, 15)
        add_positive_amount_nn_value(xml, :SocialSecurityRailRoadBenefits, :MD502_LINE_11, 15)
        add_positive_amount_nn_value(xml, :Other, :MD502_LINE_13, 15)
        add_positive_amount_nn_value(xml, :TwoIncome, :MD502_LINE_14, 15)
        add_positive_amount_nn_value(xml, :Total, :MD502_LINE_15, 15)
        add_integer_amount_if_present(xml, :StateAdjustedGrossIncome, :MD502_LINE_16, 15)
      end
      xml.Deduction do
        xml.Method calculated_fields.fetch(:MD502_DEDUCTION_METHOD)
        add_positive_amount_nn_value(xml, :Amount, :MD502_LINE_17, 15) if @deduction_method_is_standard
      end
      if @deduction_method_is_standard
        add_integer_amount_if_present(xml, :NetIncome, :MD502_LINE_18, 15)
      end
      add_positive_amount_nn_value(xml, :ExemptionAmount, :MD502_LINE_19, 15)
      if has_state_tax_computation?
        xml.StateTaxComputation do
          add_positive_amount_nn_value(xml, :TaxableNetIncome, :MD502_LINE_20, 15) if @deduction_method_is_standard
          add_positive_amount_nn_value(xml, :StateIncomeTax, :MD502_LINE_21, 15)
          add_positive_amount_nn_value(xml, :EarnedIncomeCredit, :MD502_LINE_22, 15)
          add_element_if_present(xml, "MDEICWithQualChildInd", :MD502_LINE_22B)
          add_positive_amount_nn_value(xml, :PovertyLevelCredit, :MD502_LINE_23, 15) if @deduction_method_is_standard
          add_positive_amount_nn_value(xml, :IndividualTaxCredits, :MD502_LINE_24, 15) if @deduction_method_is_standard
          add_positive_amount_nn_value(xml, :TotalCredits, :MD502_LINE_26, 15)
          add_positive_amount_nn_value(xml, :StateTaxAfterCredits, :MD502_LINE_27, 15) if @deduction_method_is_standard
        end
      end
      xml.LocalTaxComputation do
        add_element_if_present(xml, "LocalTaxRate", :MD502_LINE_28_LOCAL_TAX_RATE)
        add_positive_amount_nn_value(xml, :LocalIncomeTax, :MD502_LINE_28_LOCAL_TAX_AMOUNT, 15)
        add_positive_amount_nn_value(xml, :EarnedIncomeCredit, :MD502_LINE_29, 15)
        add_positive_amount_nn_value(xml, :PovertyLevelCredit, :MD502_LINE_30, 15)
        add_positive_amount_nn_value(xml, :TotalCredits, :MD502_LINE_32, 15)
        add_positive_amount_nn_value(xml, :LocalTaxAfterCredits, :MD502_LINE_33, 15)
      end
      add_positive_amount_nn_value(xml, :TotalStateAndLocalTax, :MD502_LINE_34, 15)
      add_positive_amount_nn_value(xml, :TotalTaxAndContributions, :MD502_LINE_39, 15)
      add_positive_amount_nn_value(xml, :TaxWithheld, :MD502_LINE_40, 15)
      add_positive_amount_nn_value(xml, :RefundableEIC, :MD502_LINE_42, 15)
      add_integer_amount_if_present(xml, :RefundableTaxCredits, :MD502_LINE_43, 15)
      add_integer_amount_if_present(xml, :TotalPaymentsAndCredits, :MD502_LINE_44, 15)
      add_positive_amount_nn_value(xml, :BalanceDue, :MD502_LINE_45, 15)
      add_positive_amount_nn_value(xml, :Overpayment, :MD502_LINE_46, 15)
      if calculated_fields.fetch(:MD502_LINE_48).positive?
        xml.AmountOverpayment do
          xml.ToBeRefunded calculated_fields.fetch(:MD502_LINE_48)
        end
      end
      add_positive_amount_nn_value(xml, :TotalAmountDue, :MD502_LINE_50, 15)
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
    end
  end

  private

  def income_section(root_xml)
    root_xml.Income do |income|
      income.FederalAdjustedGrossIncome calculated_fields.fetch(:MD502_LINE_1)
      add_positive_amount_nn_value(income, :WagesSalariesAndTips, :MD502_LINE_1A, 15)
      add_positive_amount_nn_value(income, :EarnedIncome, :MD502_LINE_1B, 15)
      add_positive_amount_nn_value(income, :TaxablePensionsIRAsAnnuities, :MD502_LINE_1D, 15)
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
