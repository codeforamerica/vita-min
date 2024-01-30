module SubmissionBuilder
  class Document
    include SubmissionBuilder::FormattingMethods
    attr_accessor :submission, :schema_file, :schema_version

    def initialize(submission, validate: true, kwargs: {})
      @submission = submission
      @validate = validate
      @schema_version = determine_default_schema_version_by_tax_year
      @kwargs = kwargs
    end

    def document
      raise "SubmissionBuilder classes must implement their own document method that returns a Nokogiri::XML::Document object"
    end

    def determine_default_schema_version_by_tax_year
      case @submission.tax_return&.year || @submission.data_source&.tax_return_year
      when 2023
        "2023v5.0"
      when 2022
        "2022v5.3"
      when 2021
        "2021v5.2"
      when 2020
        "2020v5.1"
      end
    end

    def schema_file
      raise "Child classes of SubmissionBuilder::Base must define a schema_file method."
    end

    def build
      errors = []
      if @validate
        xsd = Nokogiri::XML::Schema(File.open(schema_file))
        xml = Nokogiri::XML(document.to_xml)
        errors = xsd.validate(xml)
      end
      SubmissionBuilder::Response.new(errors: errors, document: document)
    end

    def self.build(*args)
      new(args[0], **(args[1] || {})).build
    end

    private

    COMMON_ADDRESS_ABBREV = ["bldg", "bsmt", "dept", "fl", "frnt", "hngr", "key", "lbby", "lot", "lowr", "ofc", "ph", "pier", "rear", "rm", "side", "slip", "spc", "ste", "suite", "stop", "trlr", "unit", "uppr", "Bldg", "Bsmt", "Dept", "Fl", "Frnt", "Hngr", "Key", "Lbby", "Lot", "Lowr", "Ofc", "Ph", "Pier", "Rear", "Rm", "Side", "Slip", "Spc", "Ste", "Suite", "Stop", "Trlr", "Unit", "Uppr", "APT", "BLDG", "BSMT", "DEPT", "FL", "FRNT", "HNGR", "KEY", "LBBY", "LOT", "LOWR", "OFC", "PH", "PIER", "REAR", "RM", "SIDE", "SLIP", "SPC", "STE", "SUITE", "STOP", "TRLR", "UNIT", "UPPR"].freeze

    def build_xml_doc(tag_name, **root_node_attributes)
      default_attributes = { "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" }
      xml_builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.send(tag_name, default_attributes.merge(root_node_attributes)) do |contents_builder|
          yield contents_builder if block_given?
        end
      end
      xml_builder.doc
    end

    def add_non_zero_claimed_value(xml, elem_name, claimed)
      claimed_value = calculated_fields.fetch(claimed)
      if claimed_value.present? && claimed_value.to_i != 0
        xml.send(elem_name, claimed: claimed_value)
      end
    end

    def process_mailing_street(xml)
      return unless @submission.data_source.direct_file_data.mailing_street.present?

      mailing_street = @submission.data_source.direct_file_data.mailing_street

      if mailing_street.length > 30
        process_long_mailing_street(xml, mailing_street)
      else
        xml.MAIL_LN_1_ADR @submission.data_source.direct_file_data.mailing_apartment if @submission.data_source.direct_file_data.mailing_apartment.present?
        xml.MAIL_LN_2_ADR mailing_street
      end
    end

    def process_permanent_street(xml)
      return unless @submission.data_source.permanent_street.present?

      permanent_street = @submission.data_source.permanent_street

      if permanent_street.length > 30
        process_long_permanent_street(xml, permanent_street)
      else
        xml.PERM_LN_1_ADR @submission.data_source.permanent_apartment if @submission.data_source.permanent_apartment.present?
        xml.PERM_LN_2_ADR permanent_street
      end
    end

    def process_long_mailing_street(xml, street_address)
      key_found = COMMON_ADDRESS_ABBREV.any? do |key|
        mailing_street.include?(key)
      end

      if key_found
        key_position = mailing_street.index(/\b(?:#{Regexp.union(COMMON_ADDRESS_ABBREV)})\b/)
        truncated_mailing_street = mailing_street[0, key_position].rstrip
        excess_characters = mailing_street[key_position..].lstrip
      else
        truncated_mailing_street = mailing_street[0, 30].rpartition(' ').first
        excess_characters = mailing_street[truncated_mailing_street.length + 1..]
      end

      process_mailing_apartment(xml, excess_characters, truncated_mailing_street)
    end

    def process_long_permanent_street(xml, street_address)
      key_found = COMMON_ADDRESS_ABBREV.any? do |key|
        street_address.include?(key)
      end

      if key_found
        key_position = street_address.index(/\b(?:#{Regexp.union(COMMON_ADDRESS_ABBREV)})\b/)
        truncated_street_address = street_address[0, key_position].rstrip
        excess_characters = street_address[key_position..].lstrip
      else
        truncated_street_address = street_address[0, 30].rpartition(' ').first
        excess_characters = street_address[truncated_street_address.length + 1..]
      end

      process_permanent_apartment(xml, excess_characters, truncated_street_address)
    end

    def process_permanent_apartment(xml, excess_characters, truncated_permanent_street)
      if @submission.data_source.permanent_apartment.present?
        apartment = @submission.data_source.permanent_apartment
        if apartment.length + excess_characters.length > 30
          truncated_apartment = apartment[0, 30 - excess_characters.length].rpartition(' ').first
          xml.PERM_LN_1_ADR excess_characters + " " + truncated_apartment
        else
          xml.PERM_LN_1_ADR excess_characters + " " + apartment
        end
      else
        xml.PERM_LN_1_ADR excess_characters
      end
      xml.PERM_LN_2_ADR truncated_permanent_street
    end

    def process_mailing_apartment(xml, excess_characters, truncated_mailing_street)
      if @submission.data_source.direct_file_data.mailing_apartment.present?
        apartment = @submission.data_source.direct_file_data.mailing_apartment
        if apartment.length + excess_characters.length > 30
          truncated_apartment = apartment[0, 30 - excess_characters.length].rpartition(' ').first
          xml.MAIL_LN_1_ADR excess_characters + " " + truncated_apartment
        else
          xml.MAIL_LN_1_ADR excess_characters + " " + apartment
        end
      else
        xml.MAIL_LN_1_ADR excess_characters
      end
      xml.MAIL_LN_2_ADR truncated_mailing_street
    end
  end
end
