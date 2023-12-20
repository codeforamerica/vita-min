module StateFile
  class DfIrsW2Form < QuestionsForm
    include StateFile

    SELECTORS = {
      EmployeeSSN: 'EmployeeSSN',
      EmployerEIN: 'EmployerEIN',
      EmployerNameControlTxt: 'EmployerNameControlTxt',
      AddressLine1Txt: 'EmployerUSAddress AddressLine1Txt',
      City: 'EmployerUSAddress CityNm',
      State: 'EmployerUSAddress StateAbbreviationCd',
      ZIP: 'EmployerUSAddress ZIPCd',
      WagesAmt: 'WagesAmt',
      AllocatedTipsAmt: 'AllocatedTipsAmt',
      DependentCareBenefitsAmt: 'DependentCareBenefitsAmt',
      NonqualifiedPlansAmt: 'NonqualifiedPlansAmt',
      EmployersUseGrp: {
        EmployersUseCd: 'EmployersUseGrp EmployersUseCd',
        EmployersUseAmt: 'EmployersUseGrp EmployersUseAmt'
      },
      RetirementPlanInd: 'RetirementPlanInd',
      ThirdPartySickPayInd: 'ThirdPartySickPayInd',
      OtherDeductionsBenefitsGrp: {
        Desc: 'OtherDeductionsBenefitsGrp Desc',
        Amt: 'OtherDeductionsBenefitsGrp Amt'
      },
      StateAbbreviationCd: 'W2StateTaxGrp StateAbbreviationCd',
      StateWagesAmt: 'W2StateTaxGrp StateWagesAmt',
      StateIncomeTaxAmt: 'W2StateTaxGrp StateIncomeTaxAmt',
      LocalWagesAndTipsAmt: 'W2LocalTaxGrp LocalWagesAndTipsAmt',
      LocalIncomeTaxAmt: 'W2LocalTaxGrp LocalIncomeTaxAmt',
      LocalityNm: 'W2LocalTaxGrp LocalityNm',
      WithholdingAmt: 'WithholdingAmt',
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

    SELECTORS.each do |method, selector|
      define_method(method) do
        df_xml_value(selector)&.to_i
      end

      define_method("#{method}=") do |value|
        write_df_xml_value(selector, value)
      end
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
      write_df_xml_value(__method__, value) if value.present?
    end

    def LocalIncomeTaxAmt
      df_xml_value(__method__)&.to_i
    end

    def LocalIncomeTaxAmt=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value) if value.present?
    end

    def LocalityNm
      df_xml_value(__method__)
    end

    def LocalityNm=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value) if value.present?
    end

    def persisted?
      true
    end

    def errors
      ActiveModel::Errors.new(nil)
    end
  end
end

