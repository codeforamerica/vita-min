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
    def EmployeeSSN
      df_xml_value(__method__).to_i
    end

    def EmployeeSSN=(value)
      write_df_xml_value(__method__, value)
    end

    def EmployerEIN
      df_xml_value(__method__).to_i
    end

    def EmployerEIN=(value)
      write_df_xml_value(__method__, value)
    end

    def EmployerNameControlTxt
      df_xml_value(__method__).to_i
    end

    def EmployerNameControlTxt=(value)
      write_df_xml_value(__method__, value)
    end

    def AddressLine1Txt
      df_xml_value(__method__).to_i
    end

    def AddressLine1Txt=(value)
      write_df_xml_value(__method__, value)
    end

    def City
      df_xml_value(__method__).to_i
    end

    def City=(value)
      write_df_xml_value(__method__, value)
    end

    def State
      df_xml_value(__method__).to_i
    end

    def State=(value)
      write_df_xml_value(__method__, value)
    end

    def ZIP
      df_xml_value(__method__).to_i
    end

    def ZIP=(value)
      write_df_xml_value(__method__, value)
    end

    def WagesAmt
      df_xml_value(__method__)&.to_i
    end

    def WagesAmt=(value)
      write_df_xml_value(__method__, value)
    end
    
    def box_12
      parsed_xml.css('EmployersUseGrp').map do |employer_use_grp|
        {
          code: employer_use_grp.at('EmployersUseCd')&.text,
          value: employer_use_grp.at('EmployersUseAmt')&.text
        }
      end
    end
    
    def AllocatedTipsAmt
      df_xml_value(__method__).to_i
    end

    def AllocatedTipsAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def DependentCareBenefitsAmt
      df_xml_value(__method__).to_i
    end

    def DependentCareBenefitsAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def NonqualifiedPlansAmt
      df_xml_value(__method__).to_i
    end

    def NonqualifiedPlansAmt=(value)
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

