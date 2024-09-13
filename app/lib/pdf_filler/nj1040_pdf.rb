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

      undefined_field_counter = 17
      get_dependents[0..3].map.with_index do |dependent, i|
        index_starting_at_1 = i + 1
        name = format_name(dependent[:first_name], dependent[:last_name], dependent[:middle_initial], dependent[:suffix])

        name_hash = {
          "Last Name First Name Middle Initial #{index_starting_at_1}": name
        }

        ssn_hash = {}
        birth_year_hash = {}
        text_field_start = 5
        if i == 0
          dependent[:ssn].chars.map.with_index do |char, j|
            if j <= 2
              ssn_hash["undefined_#{undefined_field_counter += 1}"] = char
            else
              ssn_hash["Text#{text_field_start}#{j + 1}"] = char
            end
            
            birth_year_hash["Birth Year"] = dependent[:birth_year][0]
            birth_year_hash["Text60"] = dependent[:birth_year][1]
            birth_year_hash["Text61"] = dependent[:birth_year][2]
            birth_year_hash["Text62"] = dependent[:birth_year][3]
          end
        else
          dependent[:ssn].chars.map.with_index do |char, j|
            if j <= 3
              ssn_hash["undefined_#{undefined_field_counter += 1}"] = char
            else
              ssn_hash["Text#{text_field_start + i}#{j + 1}"] = char
            end
          end

          dependent[:birth_year].chars.map.with_index do |char, j|
            birth_year_hash["Text#{text_field_start + 1 + i}#{j}"] = char
          end
        end

        answers.merge!(**name_hash, **ssn_hash, **birth_year_hash)
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
      @xml_document.css("Dependents DependentsName").map.with_index do |dependent, i|
        {
          first_name: dependent.at("FirstName")&.text,
          last_name: dependent.at("LastName")&.text,
          middle_initial: dependent.at("MiddleInitial")&.text,
          suffix: dependent.at("NameSuffix")&.text,
          ssn: @xml_document.css("Dependents DependentsSSN")[i]&.text,
          birth_year: @xml_document.css("Dependents BirthYear")[i]&.text,
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