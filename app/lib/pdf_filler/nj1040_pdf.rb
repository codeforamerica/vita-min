module PdfFiller
  class Nj1040Pdf
    include PdfHelper

    def source_pdf_name
      "nj1040-TY2023"
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
      spouse_ssn = get_spouse_ssn
      answers = {
        # county code
        "CM4": county_code[1],
        "CM3": county_code[2],
        "CM2": county_code[3],
        "CM1": county_code[4],

        # taxpayer ssn
        "undefined": taxpayer_ssn[0],
        "undefined_2": taxpayer_ssn[1],
        "Your Social Security Number required": taxpayer_ssn[2],
        "Text3": taxpayer_ssn[3],
        "Text4": taxpayer_ssn[4],
        "Text5": taxpayer_ssn[5],
        "Text6": taxpayer_ssn[6],
        "Text7": taxpayer_ssn[7],
        "Text8": taxpayer_ssn[8],

        # name
        "Last Name First Name Initial Joint Filers enter first name and middle initial of each Enter spousesCU partners last name ONLY if different": get_name,

        # address
        "SpousesCU Partners SSN if filing jointly": get_address, # address text field
        "CountyMunicipality Code See Table page 50": @xml_document.at("ReturnHeaderState Filer USAddress CityNm")&.text,  # city / town text field
        "State": @xml_document.at("ReturnHeaderState Filer USAddress StateAbbreviationCd")&.text,
        "ZIP Code": @xml_document.at("ReturnHeaderState Filer USAddress ZIPCd")&.text,

        # line 6 exemptions
        "Check Box39": pdf_checkbox_value(@xml_document.at("Exemptions SpouseCuRegular")),
        "Check Box40": "Off",
        "Domestic": get_line_6_exemption_count,
        "x  1000": get_line_6_exemption_count * 1000,

        # line 7 exemptions
        "Check Box41": pdf_checkbox_value(@xml_document.at("Exemptions YouOver65")),
        "Check Box42": pdf_checkbox_value(@xml_document.at("Exemptions SpouseCuPartner65OrOver")),
        "undefined_9": get_line_7_exemption_count,
        "x  1000_2": get_line_7_exemption_count * 1000,
      }

      dependents = get_dependents
      dependents[0..3].each.with_index do |dependent, i|
        name_field = dependent_pdf_keys[i][:name]
        ssn_fields = dependent_pdf_keys[i][:ssn]
        birth_year_fields = dependent_pdf_keys[i][:birth_year]
        dependent_hash = {}

        dependent_hash[name_field] = format_name(dependent[:first_name], dependent[:last_name], dependent[:middle_initial], dependent[:suffix])
        ssn_fields.each.with_index do |field_name, i|
          dependent_hash[field_name] = dependent[:ssn][i]
        end
        birth_year_fields.each.with_index do |field_name, i|
          dependent_hash[field_name] = dependent[:birth_year][i]
        end
        answers.merge!(dependent_hash)
      end

      if @xml_document.at("WagesSalariesTips").present?
        wages = @xml_document.at("WagesSalariesTips").text.to_i.digits
        answers.merge!({
           "Text106": "0",
           "Text105": "0",
           "Text104": wages[0].nil? ? "" : wages[0].to_s,
           "Text103": wages[1].nil? ? "" : wages[1].to_s,
           "Text101": wages[2].nil? ? "" : wages[2].to_s,
           "Text100": wages[3].nil? ? "" : wages[3].to_s,
           "undefined_38": wages[4].nil? ? "" : wages[4].to_s,
           "undefined_37": wages[5].nil? ? "" : wages[5].to_s,
           "undefined_36": wages[6].nil? ? "" : wages[6].to_s,
           "15": wages[7].nil? ? "" : wages[7].to_s,
         })
      end

      if spouse_ssn
        answers.merge!({
         "undefined_3": spouse_ssn[0],
         "undefined_4": spouse_ssn[1],
         "undefined_5": spouse_ssn[2],
         "Text9": spouse_ssn[3],
         "Text10": spouse_ssn[4],
         "Text11": spouse_ssn[5],
         "Text12": spouse_ssn[6],
         "Text13": spouse_ssn[7],
         "Text14": spouse_ssn[8],
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
      count = 0
      if @xml_document.at("Exemptions YouOver65")&.text == "X"
        count += 1
      end
      if @xml_document.at("Exemptions SpouseCuPartner65OrOver")&.text == "X"
        count += 1
      end
      count
    end

    def get_address
      address_line_1 = @xml_document.at("ReturnHeaderState Filer USAddress AddressLine1Txt")&.text
      address_line_2 = @xml_document.at("ReturnHeaderState Filer USAddress AddressLine2Txt")&.text
      [address_line_1, address_line_2].compact.join(" ")
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
        }
      end
    end

    def get_name
      first_name = @xml_document.at("ReturnHeaderState Filer Primary TaxpayerName FirstName")&.text
      last_name = @xml_document.at("ReturnHeaderState Filer Primary TaxpayerName LastName")&.text
      middle_initial = @xml_document.at("ReturnHeaderState Filer Primary TaxpayerName MiddleInitial")&.text
      suffix = @xml_document.at("ReturnHeaderState Filer Primary TaxpayerName NameSuffix")&.text

      spouse_first_name = @xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName FirstName")&.text
      spouse_last_name = @xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName LastName")&.text
      spouse_middle_initial = @xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName MiddleInitial")&.text
      spouse_suffix = @xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName NameSuffix")&.text

      if spouse_first_name.present? && spouse_last_name.present?
        if last_name == spouse_last_name
          return "#{format_name(first_name, last_name, middle_initial, suffix)} & #{format_no_last_name(spouse_first_name, spouse_middle_initial, spouse_suffix)}"
        else
          return "#{format_name(first_name, last_name, middle_initial, suffix)} & #{format_name(spouse_first_name, spouse_last_name, spouse_middle_initial, spouse_suffix)}"
        end
      end

      format_name(first_name, last_name, middle_initial, suffix)
    end

    def format_name(first_name, last_name, middle_initial, suffix)
      "#{last_name} #{format_no_last_name(first_name, middle_initial, suffix)}"
    end

    def format_no_last_name(first_name, middle_initial, suffix)
      [first_name, middle_initial, suffix].compact.join(" ")
    end

    def get_spouse_ssn
      @xml_document.at("ReturnHeaderState Filer Secondary TaxpayerSSN")&.text
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
          ]
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
          ]
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
          ]
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
          ]
        }
      ]
    end
  end
end