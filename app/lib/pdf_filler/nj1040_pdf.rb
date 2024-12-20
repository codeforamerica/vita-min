module PdfFiller
  class Nj1040Pdf
    include PdfHelper
    include StateFile::NjPdfHelper

    def source_pdf_name
      "nj1040-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nj)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      county_code = get_county_code
      taxpayer_ssn = get_taxpayer_ssn
      mfj_spouse_ssn = get_mfj_spouse_ssn
      mfs_spouse_ssn = get_mfs_spouse_ssn
      answers = {
        # header
        'Your Social Security Number': taxpayer_ssn.to_s,
        'Your Social Security Number_2': taxpayer_ssn.to_s,
        'Your Social Security Number_3': taxpayer_ssn.to_s,
        'Names as shown on Form NJ1040': get_name(@xml_document),
        'Names as shown on Form NJ1040_2': get_name(@xml_document),
        'Names as shown on Form NJ1040_3': get_name(@xml_document),

        # county code
        CM4: county_code[1],
        CM3: county_code[2],
        CM2: county_code[3],
        CM1: county_code[4],

        # taxpayer ssn
        undefined: taxpayer_ssn[0],
        undefined_2: taxpayer_ssn[1],
        'Your Social Security Number required': taxpayer_ssn[2],
        Text3: taxpayer_ssn[3],
        Text4: taxpayer_ssn[4],
        Text5: taxpayer_ssn[5],
        Text6: taxpayer_ssn[6],
        Text7: taxpayer_ssn[7],
        Text8: taxpayer_ssn[8],

        # name
        'Last Name First Name Initial Joint Filers enter first name and middle initial of each Enter spousesCU partners last name ONLY if different': get_name(@xml_document),

        # address
        'SpousesCU Partners SSN if filing jointly': get_address(@xml_document), # address text field
        'CountyMunicipality Code See Table page 50': @xml_document.at("ReturnHeaderState Filer USAddress CityNm")&.text, # city / town text field
        State: @xml_document.at("ReturnHeaderState Filer USAddress StateAbbreviationCd")&.text,
        'ZIP Code': @xml_document.at("ReturnHeaderState Filer USAddress ZIPCd")&.text,

        # line 6 exemptions
        'Check Box39': pdf_checkbox_value(@xml_document.at("Exemptions SpouseCuRegular")),
        'Check Box40': "Off",
        Domestic: get_line_6_exemption_count,
        'x  1000': get_line_6_exemption_count * 1000,

        # line 7 exemptions
        'Check Box41': pdf_checkbox_value(@xml_document.at("Exemptions YouOver65")),
        'Check Box42': pdf_checkbox_value(@xml_document.at("Exemptions SpouseCuPartner65OrOver")),
        undefined_9: get_line_7_exemption_count,
        'x  1000_2': get_line_7_exemption_count * 1000,

        # line 8 exemptions
        'Check Box43': pdf_checkbox_value(@xml_document.at("Exemptions YouBlindOrDisabled")),
        'Check Box44': pdf_checkbox_value(@xml_document.at("Exemptions SpouseCuPartnerBlindOrDisabled")),
        undefined_10: get_line_8_exemption_count,
        'x  1000_3': get_line_8_exemption_count * 1000,

        # line 9 exemptions
        'Check Box45': pdf_checkbox_value(@xml_document.at("Exemptions YouVeteran")),
        'Check Box46': pdf_checkbox_value(@xml_document.at("Exemptions SpouseCuPartnerVeteran")),
        undefined_11: get_line_9_exemption_count,
        'x  6000': get_line_9_exemption_count * 6000,

        Group1: filing_status,
        Group1qualwi5ab: spouse_death_year,
        Group182: household_rent_own,

        # line 53c checkbox
        'Check Box147': pdf_checkbox_value(@xml_document.at("HCCEnclosed")),

        # line 65 nj child tax credit
        '64': @xml_document.at("Body NJChildTCNumOfDep")&.text,

        # Gubernatorial elections fund
        Group245: @xml_document.at("Body PrimGubernElectFund").present? ? 'Choice1' : 'Choice2',
        Group246: if get_mfj_spouse_ssn
                    @xml_document.at("Body SpouCuPartPrimGubernElectFund").present? ? 'Choice1' : 'Choice2'
                  end,
        
        # signature fields
        'Date1_es_:signer:date': @xml_document.at("ReturnHeaderState Filer Primary DateSigned")&.text,
        'Date2_es_:signer:date': @xml_document.at("ReturnHeaderState Filer Secondary DateSigned")&.text
      }

      dependents = get_dependents
      dependents[0..3].each.with_index do |dependent, i|
        name_field = dependent_pdf_keys[i][:name]
        ssn_fields = dependent_pdf_keys[i][:ssn]
        birth_year_fields = dependent_pdf_keys[i][:birth_year]
        health_insurance_field = dependent_pdf_keys[i][:nj_did_not_have_health_insurance]
        dependent_hash = {}

        dependent_hash[name_field] = format_name(dependent[:first_name], dependent[:last_name], dependent[:middle_initial], dependent[:suffix])
        ssn_fields.each.with_index do |field_name, i|
          dependent_hash[field_name] = dependent[:ssn][i]
        end
        birth_year_fields.each.with_index do |field_name, i|
          dependent_hash[field_name] = dependent[:birth_year][i]
        end
        dependent_hash[health_insurance_field] = dependent[:nj_did_not_have_health_insurance]
        answers.merge!(dependent_hash)
      end

      # line 10
      if @xml_document.at("Header NumOfQualiDependChild")
        qualifying_children_count = @xml_document.at("Header NumOfQualiDependChild").text.to_i
        answers.merge!(
          insert_digits_into_fields(
            qualifying_children_count,
            ["undefined_12", "Text47"],
            as_decimal: false
          )
        )
        answers.merge!({ 'x  1500': calculated_fields_not_in_xml.fetch(:NJ1040_LINE_10_EXEMPTION) })
      end

      # line 11
      if @xml_document.at("Header NumOfOtherDepend")
        other_dependent_count = @xml_document.at("Header NumOfOtherDepend").text.to_i
        answers.merge!(
          insert_digits_into_fields(
            other_dependent_count,
            ["undefined_13", "Text48"],
            as_decimal: false
          )
        )
        answers.merge!({ 'x  1500_2': calculated_fields_not_in_xml.fetch(:NJ1040_LINE_11_EXEMPTION) })
      end

      # line 12
      if @xml_document.at("Exemptions DependAttendCollege")
        count = @xml_document.at("Exemptions DependAttendCollege").text.to_i
        answers.merge!(
          insert_digits_into_fields(
            count,
            ["undefined_14", "Text49"],
            as_decimal: false
          )
        )
        answers[:'x  1000_4'] = count * 1_000
      end

      # line 13
      if @xml_document.at("Exemptions TotalExemptionAmountA")
        total_exemptions = @xml_document.at("Exemptions TotalExemptionAmountA").text.to_i
        answers.merge!(insert_digits_into_fields(total_exemptions, [
                                                   "Text53",
                                                   "Text52",
                                                   "Text51",
                                                   "Text50",
                                                   "undefined_17",
                                                   "undefined_16",
                                                   "undefined_15"
                                                 ]))
      end

      # line 30
      if @xml_document.at("Body TotalExemptionAmountB")
        total_exemptions = @xml_document.at("Body TotalExemptionAmountB").text.to_i
        answers.merge!(insert_digits_into_fields(total_exemptions, [
                                                   "214",
                                                   "undefined_91",
                                                   "213",
                                                   "212",
                                                   "undefined_90",
                                                   "211",
                                                   "210",
                                                   "30"
                                                 ]))
      end

      if @xml_document.at("Body MedicalExpenses")
        medical_expenses = @xml_document.at("Body MedicalExpenses").text.to_i
        answers.merge!(insert_digits_into_fields(medical_expenses, [
                                                   "219",
                                                   "undefined_93",
                                                   "218",
                                                   "217",
                                                   "undefined_92",
                                                   "216",
                                                   "215",
                                                   "31"
                                                 ]))
      end

      if @xml_document.at("TotalExemptDeductions")
        total_exemptions = @xml_document.at("TotalExemptDeductions").text.to_i
        answers.merge!(insert_digits_into_fields(total_exemptions, [
                                                   "250",
                                                   "undefined_106",
                                                   "249",
                                                   "248",
                                                   "undefined_105",
                                                   "247",
                                                   "246",
                                                   "undefined_104",
                                                   "278",
                                                 ]))
      end

      # line 15
      if @xml_document.at("WagesSalariesTips").present?
        wages = @xml_document.at("WagesSalariesTips").text.to_i
        answers.merge!(insert_digits_into_fields(wages, [
                                                   "Text106",
                                                   "Text105",
                                                   "Text104",
                                                   "Text103",
                                                   "Text101",
                                                   "Text100",
                                                   "undefined_38",
                                                   "undefined_37",
                                                   "undefined_36",
                                                   "15"
                                                 ]))
      end

      # line 16a
      if @xml_document.at("TaxableInterestIncome")
        taxable_interest_income = @xml_document.at("TaxableInterestIncome").text.to_i
        answers.merge!(insert_digits_into_fields(taxable_interest_income, [
                                                   "112",
                                                   "111",
                                                   "110",
                                                   "109",
                                                   "108",
                                                   "Text107",
                                                   "undefined_41",
                                                   "undefined_40",
                                                   "undefined_39",
                                                   "undefined_43"
                                                 ]))
      end

      # line 16b
      if @xml_document.at("TaxexemptInterestIncome")
        tax_exempt_interest_income = @xml_document.at("TaxexemptInterestIncome").text.to_i
        answers.merge!(insert_digits_into_fields(tax_exempt_interest_income, [
                                                   "117",
                                                   "116",
                                                   "115",
                                                   "114",
                                                   "113",
                                                   "undefined_44",
                                                   "16a",
                                                   "undefined_42",
                                                   "16b"
                                                 ]))
      end

      if @xml_document.at("TotalIncome").present?
        total_income = @xml_document.at("TotalIncome").text.to_i
        answers.merge!(insert_digits_into_fields(total_income, [
                                                   "188",
                                                   "undefined_80",
                                                   "187",
                                                   "186",
                                                   "undefined_79",
                                                   "185",
                                                   "184",
                                                   "undefined_78",
                                                   "183",
                                                   "27",
                                                   "263"
                                                 ]))
      end

      if @xml_document.at("GrossIncome").present?
        gross_income = @xml_document.at("GrossIncome").text.to_i
        answers.merge!(insert_digits_into_fields(gross_income, [
                                                   "209",
                                                   "undefined_89",
                                                   "208",
                                                   "207",
                                                   "undefined_88",
                                                   "206",
                                                   "205",
                                                   "undefined_87",
                                                   "204",
                                                   "29",
                                                   "270",
                                                 ]))
      end

      # line 39
      if @xml_document.at("TaxableIncome").present?
        taxable_income = @xml_document.at("TaxableIncome").text.to_i
        answers.merge!(insert_digits_into_fields(taxable_income, [
                                                   "256",
                                                   "undefined_109",
                                                   "255",
                                                   "254",
                                                   "undefined_108",
                                                   "253",
                                                   "252",
                                                   "undefined_107",
                                                   "251",
                                                   "38a Total Property Taxes 18 of Rent Paid See instructions page 23 38a",
                                                   "279",
                                                 ]))
      end

      # line 40a
      if get_property_tax.present?
        answers.merge!(insert_digits_into_fields(get_property_tax.to_i, [
                                                   "24539a#2",
                                                   "245",
                                                   "37",
                                                   "283",
                                                   "undefined_113",
                                                   "282",
                                                   "281",
                                                   "undefined_112",
                                                   "280",
                                                   "39",
                                                 ]))
      end

      # line 41
      if @xml_document.at("PropertyTaxDeduction").present?
        property_tax_deduction = @xml_document.at("PropertyTaxDeduction").text.to_i
        answers.merge!(insert_digits_into_fields(property_tax_deduction, [
                                                   "Text18",
                                                   "Text2",
                                                   "Text1",
                                                   "undefined_118",
                                                   "undefined_117",
                                                   "41",
                                                   "undefined_116",
                                                 ]))
      end

      # line 42
      if @xml_document.at("NewJerseyTaxableIncome").present?
        nj_taxable_income = @xml_document.at("NewJerseyTaxableIncome").text.to_i
        answers.merge!(insert_digits_into_fields(nj_taxable_income, [
                                                   "Text41",
                                                   "Text40",
                                                   "Text39",
                                                   "Text38",
                                                   "Text37",
                                                   "Text30",
                                                   "Text20",
                                                   "Text19",
                                                   "undefined_114",
                                                   "40",
                                                   "Enter Code4332",
                                                 ]))
      end

      # line 43
      if @xml_document.at("Tax").present?
        tax = @xml_document.at("Tax").text.to_i
        answers.merge!(insert_digits_into_fields(tax, [
                                                   "Text63",
                                                   "Text46",
                                                   "Text45",
                                                   "Text44",
                                                   "Text43",
                                                   "undefined_120",
                                                   "undefined_119",
                                                   "42",
                                                   "4036y54ethdf",
                                                   "Enter Code4332243ew",
                                                 ]))
      end

      # line 45
      if @xml_document.at("BalanceOfTaxA").present?
        tax_balance = @xml_document.at("BalanceOfTaxA").text.to_i
        answers.merge!(insert_digits_into_fields(tax_balance, [
                                                   "Text110",
                                                   "Text109",
                                                   "Text108",
                                                   "Text102",
                                                   "Text99",
                                                   "undefined_126",
                                                   "undefined_125",
                                                   "45",
                                                   "4036y54ethdf!!!##\$$",
                                                   "Enter Code4332243ewR@434",
                                                 ]))
      end

      # line 49
      if @xml_document.at("TotalCredits").present?
        credits = @xml_document.at("TotalCredits").text.to_i
        answers.merge!(insert_digits_into_fields(credits, [
                                                   "Text125",
                                                   "Text124",
                                                   "Text123",
                                                   "Text122",
                                                   "Text121",
                                                   "undefined_132",
                                                   "undefined_131",
                                                   "48",
                                                 ]))
      end

      # line 50
      if @xml_document.at("BalanceOfTaxAfterCredit").present?
        balance_after_credits = @xml_document.at("BalanceOfTaxAfterCredit").text.to_i
        answers.merge!(insert_digits_into_fields(balance_after_credits, [
                                                   "Text130",
                                                   "Text129",
                                                   "Text128",
                                                   "Text127",
                                                   "Text126",
                                                   "undefined_134",
                                                   "undefined_133",
                                                   "49",
                                                   '4036y54ethdf\(*H', # this has to be single-quotes not double-quotes or everything will break
                                                   "Enter Code4332243ew6576z66z##",
                                                 ]))
      end

      # line 51
      if @xml_document.at("SalesAndUseTax").present?
        tax = @xml_document.at("SalesAndUseTax").text.to_i
        answers.merge!(insert_digits_into_fields(tax, [
                                                   "50_7",
                                                   "Text134",
                                                   "Text133",
                                                   "Text132",
                                                   "Text131",
                                                   "50_3",
                                                   "50_2",
                                                   "50",
                                                 ]))
      end

      # line 54
      if @xml_document.at("TotalTaxAndPenalty").present?
        total_tax_and_penalty = @xml_document.at("TotalTaxAndPenalty").text.to_i
        answers.merge!(insert_digits_into_fields(total_tax_and_penalty, [
                                                   "Text152",
                                                   "Text151",
                                                   "Text150",
                                                   "Text149",
                                                   "Text148",
                                                   "undefined_142",
                                                   "undefined_141",
                                                   "53",
                                                   "4036y54ethdf%%^87",
                                                   "Enter Code4332243ew^^%$#",
                                                 ]))
      end

      # line 55
      if @xml_document.at("TaxWithheld").present?
        tax_withheld = @xml_document.at("TaxWithheld").text.to_i
        answers.merge!(insert_digits_into_fields(tax_withheld, [
                                                   "Text157",
                                                   "Text156",
                                                   "Text155",
                                                   "Text154",
                                                   "Text153",
                                                   "undefined_145",
                                                   "undefined_144",
                                                   "undefined_143",
                                                   "Text15", # manually edited field name
                                                   "undefined_1471qerw",
                                                 ]))
      end

      # line 56
      if @xml_document.at("PropertyTaxCredit").present?
        tax = @xml_document.at("PropertyTaxCredit").text.to_i
        answers.merge!(insert_digits_into_fields(tax, [
                                                   "Text164",
                                                   "Text163",
                                                   "Text162",
                                                   "Text161",
                                                 ]))
      end

      # line 57
      if @xml_document.at("EstimatedPaymentTotal").present?
        estimated_tax_payments = @xml_document.at("EstimatedPaymentTotal").text.to_i
        answers.merge!(insert_digits_into_fields(estimated_tax_payments, [
                                                   "Text159",
                                                   "Text158",
                                                   "undefined_146",
                                                   "55",
                                                   "Text160",
                                                   "undefined_149",
                                                   "undefined_148",
                                                   "undefined_147",
                                                   "56",
                                                   "56!\#$$",
                                                 ]))
      end

      # line 58
      if @xml_document.at("EarnedIncomeCredit EarnedIncomeCreditAmount").present?
        tax = @xml_document.at("EarnedIncomeCredit EarnedIncomeCreditAmount").text.to_i
        answers.merge!(insert_digits_into_fields(tax, [
                                                   "Text172",
                                                   "Text171",
                                                   "Text170",
                                                   "undefined_153",
                                                   "undefined_152",
                                                   "58",
                                                 ]))
        answers[:'Check Box168'] = pdf_checkbox_value(@xml_document.at("EarnedIncomeCredit EICFederalAmt"))
      end


      # line 59
      if @xml_document.at("ExcessNjUiWfSwf").present?
        tax = @xml_document.at("ExcessNjUiWfSwf").text.to_i
        answers.merge!(insert_digits_into_fields(tax, [
                                                   "Text175",
                                                   "Text174",
                                                   "Text173",
                                                   "undefined_155",
                                                   "undefined_154",
                                                   "59"
                                                 ]))
      end
      
      # line 61
      if @xml_document.at("ExcesNjFamiInsur").present?
        tax = @xml_document.at("ExcesNjFamiInsur").text.to_i
        answers.merge!(insert_digits_into_fields(tax, [
                                                   "Text178",
                                                   "Text177",
                                                   "Text176",
                                                   "undefined_157",
                                                   "undefined_156",
                                                   "60"
                                                 ]))
      end

      if mfj_spouse_ssn && xml_filing_status == 'MarriedCuPartFilingJoint'
        answers.merge!({
          undefined_3: mfj_spouse_ssn[0],
          undefined_4: mfj_spouse_ssn[1],
          undefined_5: mfj_spouse_ssn[2],
          Text9: mfj_spouse_ssn[3],
          Text10: mfj_spouse_ssn[4],
          Text11: mfj_spouse_ssn[5],
          Text12: mfj_spouse_ssn[6],
          Text13: mfj_spouse_ssn[7],
          Text14: mfj_spouse_ssn[8],
        })
      end
      if mfs_spouse_ssn && xml_filing_status == 'MarriedCuPartFilingSeparate'
        answers.merge!({
          undefined_7: mfs_spouse_ssn[0],
          undefined_8: mfs_spouse_ssn[1],
          'Enter spousesCU partners SSN': mfs_spouse_ssn[2],
          Text31: mfs_spouse_ssn[3],
          Text32: mfs_spouse_ssn[4],
          Text33: mfs_spouse_ssn[5],
          Text34: mfs_spouse_ssn[6],
          Text35: mfs_spouse_ssn[7],
          Text36: mfs_spouse_ssn[8],
        })
      end

      if get_line_64_nj_child_dependent_care
        answers.merge!(insert_digits_into_fields(get_line_64_nj_child_dependent_care, [
                                                   'Text196',
                                                   'Text195',
                                                   'Text194',
                                                   'Text193',
                                                   'Text192',
                                                   'undefined_168'
                                                 ]))
      end

      if get_line_65_nj_ctc
        answers.merge!(insert_digits_into_fields(get_line_65_nj_ctc, [
                                                   "Text186",
                                                   "Text185",
                                                   "Text184",
                                                   "Text183",
                                                   "Text182",
                                                   "undefined_162",
                                                 ]))
      end

      # line 66
      if @xml_document.at("Body TotalPaymentsOrCredits").present?
        payments_or_credits = @xml_document.at("Body TotalPaymentsOrCredits").text.to_i
        answers.merge!(insert_digits_into_fields(payments_or_credits, [
                                                   "Text204",
                                                   "Text203",
                                                   "Text202",
                                                   "undefined_172",
                                                   "66",
                                                   "undefined_161",
                                                   "undefined_160",
                                                   "62",
                                                   "66page2!!",
                                                   "undefined_167",
                                                 ]))
      end

      # line 67
      if @xml_document.at("Body BalanceDueWithReturn").present?
        balance_due = @xml_document.at("Body BalanceDueWithReturn").text.to_i
        answers.merge!(insert_digits_into_fields(balance_due, [
                                                   "Text20711231167AA12vvff434te",
                                                   "Text2061ddwQz1267AA12vvff434te",
                                                   "Text20523rwefa67AA12vvff434te",
                                                   "undefined_173t24wsd67AA12vvff434te",
                                                   "672wqreafd67AA12vvff434te",
                                                   "67AA12697TDFGCXDqaffw67AA12vvff434te",
                                                   "67AA127434ERDFvfr67AA12vvff434te",
                                                   "67AA12133vvve367AA12vvff434te",
                                                   "67AA12vvff434te",
                                                   "67AA12vvff434tei7yt#",
                                                 ]))
      end

      # line 68
      if @xml_document.at("Body OverpaymentAmount").present?
        overpayment = @xml_document.at("Body OverpaymentAmount").text.to_i
        answers.merge!(insert_digits_into_fields(overpayment, [
                                                   "Text23312###5z564312###5z5643",
                                                   "Text23212###5z564312###5z5643",
                                                   "Text23112###5z564312###5z5643",
                                                   "Text23012###5z564312###5z5643",
                                                   "Text22912###5z564312###5z5643",
                                                   "undefined_18312###5z564312###5z5643",
                                                   "undefined_18212###5z564312###5z5643",
                                                   "undefined_18112###5z564312###5z5643",
                                                   "7412###5z564312###5z5643",
                                                   "74112###5z5643",
                                                 ]))
      end

      # line 78
      if @xml_document.at("Body TotalAdjustments").present?
        adjustments = @xml_document.at("Body TotalAdjustments").text.to_i
        answers.merge!(insert_digits_into_fields(adjustments, [
                                                   "Text233",
                                                   "Text232",
                                                   "Text231",
                                                   "Text230",
                                                   "Text229",
                                                   "undefined_183",
                                                   "undefined_182",
                                                   "undefined_181",
                                                   "74",
                                                   "74112###",
                                                 ]))
      end

      # line 79
      if @xml_document.at("Body NetBalanceDue").present?
        balance_due = @xml_document.at("Body NetBalanceDue").text.to_i
        answers.merge!(insert_digits_into_fields(balance_due, [
                                                   "Text238",
                                                   "Text237",
                                                   "Text236",
                                                   "Text235",
                                                   "Text234",
                                                   "undefined_186",
                                                   "undefined_185",
                                                   "undefined_184",
                                                   "75",
                                                   "754112###",
                                                 ]))
      end

      # line 80
      if @xml_document.at("Body NetRefund").present?
        refund = @xml_document.at("Body NetRefund").text.to_i
        answers.merge!(insert_digits_into_fields(refund, [
                                                   "Text244",
                                                   "Text243",
                                                   "Text242",
                                                   "Text241",
                                                   "Text240",
                                                   "undefined_189",
                                                   "undefined_188",
                                                   "undefined_187",
                                                   "76",
                                                   "764112###",
                                                 ]))
      end
      
      # Driver License/State ID
      id_number_xml = @xml_document.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsNum") ||
                      @xml_document.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdNum")
      if id_number_xml.present?
        id_number = id_number_xml&.text
        answers.merge!({
          'Drivers License Number Voluntary Instructions page 44': id_number[0],
          Text246: id_number[1],
          Text247: id_number[2],
          Text248: id_number[3],
          Text249: id_number[4],
          Text250: id_number[5],
          Text251: id_number[6],
          Text252: id_number[7],
          Text253: id_number[8],
          Text254: id_number[9],
          Text255: id_number[10],
          Text256: id_number[11],
          Text257: id_number[12],
          Text258: id_number[13],
          Text259: id_number[14]
        })
      end

      answers
    end

    private

    def pdf_checkbox_value(checkbox_xml)
      checkbox_xml&.text == "X" ? "Yes" : "Off"
    end

    def get_county_code
      @xml_document.at("ReturnDataState FormNJ1040 Header CountyCode")&.text
    end

    def get_taxpayer_ssn
      @xml_document.at("ReturnHeaderState Filer Primary TaxpayerSSN")&.text
    end

    def get_line_6_exemption_count
      @xml_document.at("Exemptions SpouseCuRegular")&.text == "X" ? 2 : 1
    end

    def get_line_7_exemption_count
      get_total_exemption_count(["Exemptions YouOver65", "Exemptions SpouseCuPartner65OrOver"])
    end

    def get_line_8_exemption_count
      get_total_exemption_count(["Exemptions YouBlindOrDisabled", "Exemptions SpouseCuPartnerBlindOrDisabled"])
    end

    def get_line_9_exemption_count
      get_total_exemption_count(["Exemptions YouVeteran", "Exemptions SpouseCuPartnerVeteran"])
    end

    def get_total_exemption_count(xml_selector_string_array)
      xml_selector_string_array.sum { |selector| @xml_document.at(selector)&.text == "X" ? 1 : 0 }
    end

    def get_dependents
      @xml_document.css("Dependents").map do |dependent|
        {
          first_name: dependent.at("DependentsName FirstName")&.text,
          last_name: dependent.at("DependentsName LastName")&.text,
          middle_initial: dependent.at("DependentsName MiddleInitial")&.text,
          suffix: dependent.at("DependentsName NameSuffix")&.text,
          ssn: dependent.at("DependentsSSN")&.text,
          birth_year: dependent.at("BirthYear")&.text,
          nj_did_not_have_health_insurance: pdf_checkbox_value(dependent.at("NoHealthInsurance")),
        }
      end
    end

    def insert_digits_into_fields(number, fields_ordered_decimals_to_millions, as_decimal: true)
      digits = number.digits
      digits_hash = {}

      start_index = as_decimal ? 2 : 0

      if as_decimal
        digits_hash[fields_ordered_decimals_to_millions[0]] = "0"
        digits_hash[fields_ordered_decimals_to_millions[1]] = "0"
      end

      fields_ordered_decimals_to_millions[start_index..].each.with_index do |field, i|
        digits_hash[field] = digits[i].nil? ? "" : digits[i].to_s
      end

      digits_hash
    end

    def dependent_pdf_keys
      [
        {
          name: "Last Name First Name Middle Initial 1",
          ssn: [
            "undefined_18",
            "undefined_19",
            "undefined_20",
            "Text54",
            "Text55",
            "Text56",
            "Text57",
            "Text58",
            "Text59"
          ],
          birth_year: [
            "Birth Year",
            "Text60",
            "Text61",
            "Text62"
          ],
          nj_did_not_have_health_insurance: "Check Box63"
        },
        {
          name: "Last Name First Name Middle Initial 2",
          ssn: [
            "undefined_21",
            "undefined_22",
            "undefined_23",
            "undefined_24",
            "Text65",
            "Text66",
            "Text67",
            "Text68",
            "Text69"
          ],
          birth_year: [
            "Text70",
            "Text71",
            "Text72",
            "Text73"
          ],
          nj_did_not_have_health_insurance: "Check Box74"
        },
        {
          name: "Last Name First Name Middle Initial 3",
          ssn: [
            "undefined_25",
            "undefined_26",
            "undefined_27",
            "undefined_28",
            "Text75",
            "Text76",
            "Text77",
            "Text78",
            "Text79"
          ],
          birth_year: [
            "Text80",
            "Text81",
            "Text82",
            "Text83"
          ],
          nj_did_not_have_health_insurance: "Check Box84"
        },
        {
          name: "Last Name First Name Middle Initial 4",
          ssn: [
            "undefined_29",
            "undefined_30",
            "undefined_31",
            "undefined_32",
            "Text85",
            "Text86",
            "Text87",
            "Text88",
            "Text89"
          ],
          birth_year: [
            "Text90",
            "Text91",
            "Text92",
            "Text93"
          ],
          nj_did_not_have_health_insurance: "Check Box94"
        }
      ]
    end

    def get_mfj_spouse_ssn
      @xml_document.at("ReturnHeaderState Filer Secondary TaxpayerSSN")&.text
    end

    def get_mfs_spouse_ssn
      @xml_document.at("MarriedCuPartFilingSeparate SpouseSSN")&.text
    end

    FILING_STATUS_OPTIONS = {
      "Single" => "Choice1",
      "MarriedCuPartFilingJoint" => "Choice2",
      "MarriedCuPartFilingSeparate" => "Choice3",
      "HeadOfHousehold" => "Choice4",
      "QualWidOrWider" => "Choice5"
    }.freeze

    def xml_filing_status
      @xml_document.at("FilingStatus")&.children&.first&.name
    end

    def filing_status
      FILING_STATUS_OPTIONS[xml_filing_status]
    end

    def spouse_death_year
      return nil if xml_filing_status != "QualWidOrWider"
      return "1" if @xml_document.at("QualWidOrWider LastYear")&.text == 'X'
      return "0" if @xml_document.at("QualWidOrWider TwoYearPrior")&.text == 'X'
    end

    def household_rent_own
      return "Choice1" if @xml_document.at("PropertyTaxDeductOrCredit Homeowner")&.text == 'X'
      return "Choice2" if @xml_document.at("PropertyTaxDeductOrCredit Tenant")&.text == 'X'
      "Off"
    end

    def get_property_tax
      @xml_document.at("PropertyTaxDeductOrCredit TotalPropertyTaxPaid")&.text
    end

    def get_line_64_nj_child_dependent_care
      @xml_document.at('ChildDependentCareCredit')&.text.to_i
    end

    def get_line_65_nj_ctc
      @xml_document.at("Body NJChildTaxCredit")&.text.to_i
    end

    def calculated_fields_not_in_xml
      @calculated_fields_not_in_xml ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
