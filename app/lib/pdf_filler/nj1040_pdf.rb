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
      if dependents[0]
        dep0 = dependents[0]
        name = format_name(dep0[:first_name], dep0[:last_name], dep0[:middle_initial], dep0[:suffix])
        answers.merge!({
          "Last Name First Name Middle Initial 1": name,
          "undefined_18": dep0[:ssn][0],
          "undefined_19": dep0[:ssn][1],
          "undefined_20": dep0[:ssn][2],
          "Text54": dep0[:ssn][3],
          "Text55": dep0[:ssn][4],
          "Text56": dep0[:ssn][5],
          "Text57": dep0[:ssn][6],
          "Text58": dep0[:ssn][7],
          "Text59": dep0[:ssn][8],
          "Birth Year": dep0[:birth_year][0],
          "Text60": dep0[:birth_year][1],
          "Text61": dep0[:birth_year][2],
          "Text62": dep0[:birth_year][3]
        })
      end

      if dependents[1]
        dep1 = dependents[1]
        name = format_name(dep1[:first_name], dep1[:last_name], dep1[:middle_initial], dep1[:suffix])
        answers.merge!({
           "Last Name First Name Middle Initial 2": name,
           "undefined_21": dep1[:ssn][0],
           "undefined_22": dep1[:ssn][1],
           "undefined_23": dep1[:ssn][2],
           "undefined_24": dep1[:ssn][3],
           "Text65": dep1[:ssn][4],
           "Text66": dep1[:ssn][5],
           "Text67": dep1[:ssn][6],
           "Text68": dep1[:ssn][7],
           "Text69": dep1[:ssn][8],
           "Text70": dep1[:birth_year][0],
           "Text71": dep1[:birth_year][1],
           "Text72": dep1[:birth_year][2],
           "Text73": dep1[:birth_year][3]
         })
      end

      if dependents[2]
        dep2 = dependents[2]
        name = format_name(dep2[:first_name], dep2[:last_name], dep2[:middle_initial], dep2[:suffix])
        answers.merge!({
         "Last Name First Name Middle Initial 3": name,
         "undefined_25": dep2[:ssn][0],
         "undefined_26": dep2[:ssn][1],
         "undefined_27": dep2[:ssn][2],
         "undefined_28": dep2[:ssn][3],
         "Text75": dep2[:ssn][4],
         "Text76": dep2[:ssn][5],
         "Text77": dep2[:ssn][6],
         "Text78": dep2[:ssn][7],
         "Text79": dep2[:ssn][8],
         "Text80": dep2[:birth_year][0],
         "Text81": dep2[:birth_year][1],
         "Text82": dep2[:birth_year][2],
         "Text83": dep2[:birth_year][3]
       })
      end

      if dependents[3]
        dep3 = dependents[3]
        name = format_name(dep3[:first_name], dep3[:last_name], dep3[:middle_initial], dep3[:suffix])
        answers.merge!({
           "Last Name First Name Middle Initial 4": name,
           "undefined_29": dep3[:ssn][0],
           "undefined_30": dep3[:ssn][1],
           "undefined_31": dep3[:ssn][2],
           "undefined_32": dep3[:ssn][3],
           "Text85": dep3[:ssn][4],
           "Text86": dep3[:ssn][5],
           "Text87": dep3[:ssn][6],
           "Text88": dep3[:ssn][7],
           "Text89": dep3[:ssn][8],
           "Text90": dep3[:birth_year][0],
           "Text91": dep3[:birth_year][1],
           "Text92": dep3[:birth_year][2],
           "Text93": dep3[:birth_year][3]
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
  end
end