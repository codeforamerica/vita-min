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
                       :total_state_tax_withheld,
                       :total_exempt_primary_spouse

    validate :direct_file_data_must_be_imported
    validate :dependent_detail_ssns_must_be_unique
    validate :qualifying_child_information_ssns_must_be_in_dependent_detail

    def self.nested_attribute_names
      {
        w2s_attributes: DfIrsW2Form::SELECTORS.keys,
        form1099rs_attributes: DirectFileData::Df1099R::SELECTORS.keys,
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
        DfIrsW2Form::SELECTORS.each_key do |field|
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
        DfIrs1099RForm::SELECTORS.each_key do |field|
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

    class DfIrsW2Form
      include DfXmlCrudMethods

      SELECTORS = {
        WagesAmt: 'WagesAmt',
        WithholdingAmt: 'WithholdingAmt',
        StateWagesAmt: 'W2StateLocalTaxGrp W2StateTaxGrp StateWagesAmt',
        StateIncomeTaxAmt: 'W2StateLocalTaxGrp W2StateTaxGrp StateIncomeTaxAmt',
        LocalWagesAndTipsAmt: 'W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalWagesAndTipsAmt',
        LocalIncomeTaxAmt: 'W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalIncomeTaxAmt',
        LocalityNm: 'W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalityNm',
      }

      attr_reader :node
      attr_accessor :id
      attr_accessor *SELECTORS.keys
      attr_accessor :_destroy

      def selectors
        SELECTORS
      end

      def initialize(node = nil)
        @node = if node
          node
        else
          Nokogiri::XML(IrsApiService.df_return_sample).at('IRSW2')
        end
      end

      def id
        @node['documentId']
      end

      def WagesAmt
        df_xml_value(__method__)&.to_i
      end

      def WagesAmt=(value)
        write_df_xml_value(__method__, value)
      end

      def WithholdingAmt
        df_xml_value(__method__)&.to_i
      end

      def WithholdingAmt=(value)
        write_df_xml_value(__method__, value)
      end

      def StateWagesAmt
        df_xml_value(__method__)&.to_i
      end

      def StateWagesAmt=(value)
        create_or_destroy_df_xml_node(__method__, value)
        write_df_xml_value(__method__, value)
      end

      def StateIncomeTaxAmt
        df_xml_value(__method__)&.to_i
      end

      def StateIncomeTaxAmt=(value)
        create_or_destroy_df_xml_node(__method__, value)
        write_df_xml_value(__method__, value)
      end

      def LocalWagesAndTipsAmt
        df_xml_value(__method__)&.to_i
      end

      def LocalWagesAndTipsAmt=(value)
        create_or_destroy_df_xml_node(__method__, value)
        if value.present?
          write_df_xml_value(__method__, value)
        end
      end

      def LocalIncomeTaxAmt
        df_xml_value(__method__)&.to_i
      end

      def LocalIncomeTaxAmt=(value)
        create_or_destroy_df_xml_node(__method__, value)
        if value.present?
          write_df_xml_value(__method__, value)
        end
      end

      def LocalityNm
        df_xml_value(__method__)
      end

      def LocalityNm=(value)
        create_or_destroy_df_xml_node(__method__, value)
        if value.present?
          write_df_xml_value(__method__, value)
        end
      end

      def persisted?
        true
      end

      def errors
        ActiveModel::Errors.new(nil)
      end
    end

    class DfIrs1099RForm
      include DfXmlCrudMethods

      SELECTORS = {
        PayerNameControlTxt: "PayerNameControlTxt",
        PayerName: "PayerName BusinessNameLine1Txt",
        AddressLine1Txt: "PayerUSAddress AddressLine1Txt",
        CityNm: "PayerUSAddress CityNm",
        StateAbbreviationCd: "PayerUSAddress StateAbbreviationCd",
        ZIPCd: "PayerUSAddress ZIPCd",
        PayerEIN: "PayerEIN",
        PhoneNum: "PhoneNum",
        GrossDistributionAmt: "GrossDistributionAmt",
        TaxableAmt: "TaxableAmt",
        FederalIncomeTaxWithheldAmt: "FederalIncomeTaxWithheldAmt",
        F1099RDistributionCd: "F1099RDistributionCd",
        StandardOrNonStandardCd: "StandardOrNonStandardCd",
      }

      attr_reader :node
      attr_accessor :id
      attr_accessor *SELECTORS.keys
      attr_accessor :_destroy

      def selectors
        SELECTORS
      end

      def initialize(node = nil)
        @node = if node
                  node
                else
                  Nokogiri::XML(StateFile::XmlReturnSampleService.new.read("az_retirement")).at('IRS1099R')
                end
      end

      def id
        @node['documentId']
      end

      def PayerNameControlTxt
        df_xml_value(__method__)
      end

      def PayerNameControlTxt=(value)
        write_df_xml_value(__method__, value)
      end

      def PayerName
        df_xml_value(__method__)
      end

      def PayerName=(value)
        write_df_xml_value(__method__, value)
      end

      def AddressLine1Txt
        df_xml_value(__method__)
      end

      def AddressLine1Txt=(value)
        write_df_xml_value(__method__, value)
      end

      def CityNm
        df_xml_value(__method__)
      end

      def CityNm=(value)
        write_df_xml_value(__method__, value)
      end

      def StateAbbreviationCd
        df_xml_value(__method__)
      end

      def StateAbbreviationCd=(value)
        write_df_xml_value(__method__, value)
      end

      def ZIPCd
        df_xml_value(__method__)
      end

      def ZIPCd=(value)
        write_df_xml_value(__method__, value)
      end

      def PayerEIN
        df_xml_value(__method__)
      end

      def PayerEIN=(value)
        write_df_xml_value(__method__, value)
      end

      def PhoneNum
        df_xml_value(__method__)
      end

      def PhoneNum=(value)
        write_df_xml_value(__method__, value)
      end

      def GrossDistributionAmt
        df_xml_value(__method__)
      end

      def GrossDistributionAmt=(value)
        write_df_xml_value(__method__, value)
      end

      def TaxableAmt
        df_xml_value(__method__)
      end

      def TaxableAmt=(value)
        write_df_xml_value(__method__, value)
      end

      def FederalIncomeTaxWithheldAmt
        df_xml_value(__method__)
      end

      def FederalIncomeTaxWithheldAmt=(value)
        write_df_xml_value(__method__, value)
      end

      def F1099RDistributionCd
        df_xml_value(__method__)
      end

      def F1099RDistributionCd=(value)
        write_df_xml_value(__method__, value)
      end

      def StandardOrNonStandardCd
        df_xml_value(__method__)
      end

      def StandardOrNonStandardCd=(value)
        write_df_xml_value(__method__, value)
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