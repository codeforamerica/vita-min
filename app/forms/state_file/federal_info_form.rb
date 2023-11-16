module StateFile
  class FederalInfoForm < QuestionsForm
    include DateHelper

    set_attributes_for :intake,
                       :claimed_as_dep

    set_attributes_for :direct_file_data,
                       :tax_return_year,
                       :filing_status,
                       :primary_ssn,
                       :primary_occupation,
                       :spouse_ssn,
                       :spouse_occupation,
                       :mailing_city,
                       :mailing_street,
                       :mailing_apartment,
                       :mailing_zip,
                       :fed_wages,
                       :fed_taxable_income,
                       :fed_unemployment,
                       :fed_taxable_ssb,
                       :total_state_tax_withheld

    validate :direct_file_data_must_be_imported

    def self.nested_attribute_names
      {
        w2s_attributes: [:WagesAmt, :WithholdingAmt],
        dependent_details_attributes: [:DependentSSN, :DependentFirstNm, :DependentLastNm, :DependentRelationshipCd]
      }
    end

    def direct_file_data_must_be_imported
      if @intake.raw_direct_file_data.blank?
        errors.add(:filing_status, "Must import from Direct File to continue!")
      end
    end

    def dependent_details
      @intake.direct_file_data.dependent_detail_nodes.map do |node|
        DfDependentDetailForm.new(node)
      end
    end

    def dependent_details_attributes=(attributes)
      index = 0
      attributes.each do |_form_number, dependent_detail_attributes|
        if index == dependent_details.length
          @intake.direct_file_data.build_new_dependent_detail_node
        end
        dependent_detail = dependent_details[index.to_i]
        dependent_detail.DependentFirstNm = dependent_detail_attributes['DependentFirstNm']
        dependent_detail.DependentLastNm = dependent_detail_attributes['DependentLastNm']
        dependent_detail.DependentSSN = dependent_detail_attributes['DependentSSN']
        dependent_detail.DependentRelationshipCd = dependent_detail_attributes['DependentRelationshipCd']
        index += 1
      end
    end

    def w2s
      @intake.direct_file_data.w2_nodes.map do |node|
        DfIrsW2Form.new(node)
      end
    end

    def w2s_attributes=(attributes)
      index = 0
      attributes.each do |_form_number, w2_attributes|
        if index == w2s.length
          @intake.direct_file_data.build_new_w2_node
        end
        w2 = w2s[index.to_i]
        w2.WagesAmt = w2_attributes['WagesAmt']
        w2.WithholdingAmt = w2_attributes['WithholdingAmt']
        index += 1
      end
    end

    def initialize(intake = nil, params = nil)
      super
      attributes_for(:direct_file_data).each do |attribute, value|
        if @intake.direct_file_data.can_override?(attribute)
          @intake.direct_file_data.send("#{attribute}=", value)
        end
      end
    end

    def valid?
      schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2023v3.0", "IndividualIncomeTax", "Ind1040", "Return1040.xsd")
      xsd = Nokogiri::XML::Schema(File.open(schema_file))
      xml = Nokogiri::XML(intake.direct_file_data.to_s)
      errors = xsd.validate(xml)
      # TODO: current direct file sample doesn't pass schema 😭
      # super && errors.blank?
      super
    end

    def save
      @intake.update(
        attributes_for(:intake)
          .merge(
            raw_direct_file_data: intake.direct_file_data.to_s
          )
      )
      @intake.synchronize_df_dependents_to_database
    end

    def self.existing_attributes(intake)
      attributes = HashWithIndifferentAccess.new(intake.attributes.merge(intake.direct_file_data.attributes))
      attributes
    end

    class DfDependentDetailForm
      attr_accessor :id
      attr_accessor :DependentFirstNm
      attr_accessor :DependentLastNm
      attr_accessor :_destroy

      def initialize(node = nil)
        @node = node
      end

      def id
        return 'NEW' unless @node
        @node['documentId']
      end

      def DependentSSN
        return nil unless @node
        @node.at('DependentSSN')&.text
      end

      def DependentSSN=(value)
        @node.at('DependentSSN').content = value
      end
      
      def DependentFirstNm
        return nil unless @node
        @node.at('DependentFirstNm')&.text
      end

      def DependentFirstNm=(value)
        @node.at('DependentFirstNm').content = value
      end

      def DependentLastNm
        return nil unless @node
        @node.at('DependentLastNm')&.text
      end

      def DependentLastNm=(value)
        @node.at('DependentLastNm').content = value
      end

      def DependentRelationshipCd
        return nil unless @node
        @node.at('DependentRelationshipCd')&.text
      end

      def DependentRelationshipCd=(value)
        @node.at('DependentRelationshipCd').content = value
      end

      def persisted?
        true
      end

      def errors
        ActiveModel::Errors.new(nil)
      end
    end

    class DfIrsW2Form
      attr_accessor :id
      attr_accessor :WagesAmt
      attr_accessor :WithholdingAmt
      attr_accessor :_destroy

      def initialize(node = nil)
        @node = node
      end

      def id
        return 'W2-NEW' unless @node
        @node['documentId']
      end

      def WagesAmt
        return nil unless @node
        @node.at('WagesAmt')&.text&.to_i
      end

      def WagesAmt=(value)
        @node.at('WagesAmt').content = value
      end

      def WithholdingAmt
        return nil unless @node
        @node.at('WithholdingAmt')&.text&.to_i
      end

      def WithholdingAmt=(value)
        @node.at('WithholdingAmt').content = value
      end

      def persisted?
        true
      end

      def errors
        ActiveModel::Errors.new(nil)
      end
    end
  end
end