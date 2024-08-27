module StateFile
  class FederalInfoForm < QuestionsForm
    include DateHelper

    set_attributes_for :intake

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
                       :fed_agi,
                       :fed_wages,
                       :fed_taxable_income,
                       :fed_unemployment,
                       :fed_taxable_ssb,
                       :fed_taxable_pensions,
                       :total_state_tax_withheld,
                       :total_exempt_primary_spouse

    validate :direct_file_data_must_be_imported
    validate :dependent_detail_ssns_must_be_unique
    validate :qualifying_child_information_ssns_must_be_in_dependent_detail

    def self.nested_attribute_names
      {
        w2s_attributes: DfIrsW2Form::SELECTORS.keys,
        form1099rs_attributes: DfIrs1099RForm::SELECTORS.keys,
        dependent_details_attributes: DfDependentDetailForm::SELECTORS.keys,
        qualifying_child_informations_attributes: DfQualifyingChildInformationForm::SELECTORS.keys
      }
    end

    def direct_file_data_must_be_imported
      if @intake.raw_direct_file_data.blank?
        errors.add(:filing_status, "Must import from Direct File to continue!")
      end
    end

    def dependent_detail_ssns_must_be_unique
      dependent_details_ssns = dependent_details.map(&:DependentSSN)
      if dependent_details_ssns.uniq.length < dependent_details.length
        errors.add(:base, "Dependent Details must have unique SSNs. You entered: #{dependent_details_ssns.sort.join(', ')}")
      end
    end

    def qualifying_child_information_ssns_must_be_in_dependent_detail
      dependent_details_ssns = dependent_details.map(&:DependentSSN)
      qualifying_child_information_ssns = qualifying_child_informations.map(&:QualifyingChildSSN)
      missing_ssns = qualifying_child_information_ssns - dependent_details_ssns
      if missing_ssns.length > 0
        errors.add(:base, "Qualifying Child Information SSNs must also exist in DependentDetail. Missing: #{missing_ssns.sort.join(', ')}")
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
        DfDependentDetailForm::SELECTORS.each_key do |field|
          dependent_detail.send(:"#{field}=", dependent_detail_attributes[field.to_s])  
        end
        index += 1
      end
    end

    def qualifying_child_informations
      @intake.direct_file_data.qualifying_child_information_nodes.map do |node|
        DfQualifyingChildInformationForm.new(node)
      end
    end

    def qualifying_child_informations_attributes=(attributes)
      index = 0
      attributes.each do |_form_number, qualifying_child_information_attributes|
        if index == qualifying_child_informations.length
          @intake.direct_file_data.build_new_qualifying_child_information_node
        end
        qualifying_child_information = qualifying_child_informations[index.to_i]
        DfQualifyingChildInformationForm::SELECTORS.each_key do |field|
          qualifying_child_information.send(:"#{field}=", qualifying_child_information_attributes[field.to_s])
        end
        index += 1
      end
    end

    def w2s
      @intake.direct_file_data.w2_nodes.map do |node|
        DfIrsW2Form.new(node)
      end
    end

    def form1099rs
      @intake.direct_file_data.form1099r_nodes.map do |node|
        DfIrs1099RForm.new(node)
      end
    end

    def w2s_attributes=(attributes)
      index = 0
      attributes.each do |_form_number, w2_attributes|
        if index == w2s.length
          @intake.direct_file_data.build_new_w2_node
        end
        w2 = w2s[index.to_i]
        DfIrsW2Form.selectors.each_key do |field|
          w2.send(:"#{field}=", w2_attributes[field.to_s])
        end
        index += 1
      end
    end

    def form1099rs_attributes=(attributes)
      index = 0
      attributes.each do |_form_number, form1099r_attributes|
        if index == form1099rs.length
          @intake.direct_file_data.build_new_1099r_node
        end
        form1099r = form1099rs[index.to_i]
        DfIrs1099RForm.selectors.each_key do |field|
          form1099r.send(:"#{field}=", form1099r_attributes[field.to_s])
        end
        index += 1
      end
    end

    def initialize(intake = nil, params = nil)
      super
      attributes_for(:direct_file_data).each do |attribute, value|
        if @intake.direct_file_data.can_override?(attribute)
          if @intake.direct_file_data.send(attribute) != value
            @intake.direct_file_data.send("#{attribute}=", value)
          end
        end
      end
    end

    def save
      @intake.update(
        attributes_for(:intake)
          .merge(
            raw_direct_file_data: intake.direct_file_data.to_s
          )
      )
      @intake.update(hashed_ssn: SsnHashingService.hash(intake.direct_file_data.primary_ssn))
      @intake.synchronize_df_dependents_to_database
    end

    def self.existing_attributes(intake)
      HashWithIndifferentAccess.new(intake.attributes.merge(intake.direct_file_data.attributes))
    end

    class DfDependentDetailForm
      include DfXmlCrudMethods

      SELECTORS = {
        DependentSSN: 'DependentSSN',
        DependentFirstNm: 'DependentFirstNm',
        DependentLastNm: 'DependentLastNm',
        DependentRelationshipCd: 'DependentRelationshipCd',
      }

      attr_reader :node
      attr_accessor :id
      attr_accessor *SELECTORS.keys
      attr_accessor :_destroy

      def selectors
        SELECTORS
      end

      def initialize(node = nil)
        if node
          @node = node
        else
          @node = Nokogiri::XML(IrsApiService.df_return_sample).at('DependentDetail')
          @node.at('DependentFirstNm').content = "Testfirst"
          @node.at('DependentLastNm').content = "Testlast"
        end
      end

      def id
        nil
      end

      def DependentSSN
        df_xml_value(__method__)
      end

      def DependentSSN=(value)
        write_df_xml_value(__method__, value)
      end
      
      def DependentFirstNm
        df_xml_value(__method__)
      end

      def DependentFirstNm=(value)
        write_df_xml_value(__method__, value)
      end

      def DependentLastNm
        df_xml_value(__method__)
      end

      def DependentLastNm=(value)
        write_df_xml_value(__method__, value)
      end

      def DependentRelationshipCd
        df_xml_value(__method__)
      end

      def DependentRelationshipCd=(value)
        write_df_xml_value(__method__, value)
      end

      def persisted?
        true
      end

      def errors
        ActiveModel::Errors.new(nil)
      end
    end

    class DfQualifyingChildInformationForm
      include DfXmlCrudMethods

      SELECTORS = {
        QualifyingChildSSN: 'QualifyingChildSSN',
        ChildRelationshipCd: 'ChildRelationshipCd',
      }

      attr_reader :node
      attr_accessor :id
      attr_accessor *SELECTORS.keys
      attr_accessor :_destroy

      def selectors
        SELECTORS
      end

      def initialize(node = nil)
        if node
          @node = node
        else
          @node = Nokogiri::XML(IrsApiService.df_return_sample).at('QualifyingChildInformation')
        end
      end

      def id
        nil
      end

      def QualifyingChildSSN
        df_xml_value(__method__)
      end

      def QualifyingChildSSN=(value)
        write_df_xml_value(__method__, value)
      end

      def ChildRelationshipCd
        df_xml_value(__method__)
      end

      def ChildRelationshipCd=(value)
        write_df_xml_value(__method__, value)
      end

      def persisted?
        true
      end

      def errors
        ActiveModel::Errors.new(nil)
      end
    end

    class DfIrsW2Form < DfW2Accessor
      attr_accessor :id
      attr_accessor :_destroy

      def id
        @node['documentId']
      end

      def persisted?
        true
      end

      def errors
        ActiveModel::Errors.new(nil)
      end
    end

    class DfIrs1099RForm < Df1099rAccessor
      attr_accessor :id
      attr_accessor :_destroy

      def id
        @node['documentId']
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