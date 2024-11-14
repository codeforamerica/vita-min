module NjPdfHelper
  def get_name(nj_1040_xml_document, include_spouse: true, spouse_only: false)
    first_name = nj_1040_xml_document.at("ReturnHeaderState Filer Primary TaxpayerName FirstName")&.text
    last_name = nj_1040_xml_document.at("ReturnHeaderState Filer Primary TaxpayerName LastName")&.text
    middle_initial = nj_1040_xml_document.at("ReturnHeaderState Filer Primary TaxpayerName MiddleInitial")&.text
    suffix = nj_1040_xml_document.at("ReturnHeaderState Filer Primary TaxpayerName NameSuffix")&.text

    spouse_first_name = nj_1040_xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName FirstName")&.text
    spouse_last_name = nj_1040_xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName LastName")&.text
    spouse_middle_initial = nj_1040_xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName MiddleInitial")&.text
    spouse_suffix = nj_1040_xml_document.at("ReturnHeaderState Filer Secondary TaxpayerName NameSuffix")&.text

    if spouse_only
      return format_name(spouse_first_name, spouse_last_name, spouse_middle_initial, spouse_suffix)
    end

    if include_spouse && spouse_first_name.present? && spouse_last_name.present?
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

  def get_address(nj_1040_xml_document)
    address_line_1 = nj_1040_xml_document.at("ReturnHeaderState Filer USAddress AddressLine1Txt")&.text
    address_line_2 = nj_1040_xml_document.at("ReturnHeaderState Filer USAddress AddressLine2Txt")&.text
    [address_line_1, address_line_2].compact.join(" ")
  end
end
