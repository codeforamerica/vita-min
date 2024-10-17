module SubmissionBuilder
  class ReturnW2 < SubmissionBuilder::Document
    def document
      w2 = @kwargs[:w2]

      build_xml_doc("IRSW2", documentId: "W2000-#{w2.id}") do |xml|
        # xml.EmployeeSSN _
        # xml.EmployerEIN _
        # xml.EmployerNameControlTxt
        xml.EmployerName do
          xml.BusinessNameLine1Txt w2.employer_name
        end
        # xml.EmployerUSAddress do
        #   xml.AddressLine1Txt
        #   xml.CityNm
        #   xml.StateAbbreviationCd
        #   xml.ZIPCd
        # end
        xml.EmployeeNm w2.employee_name
        #       <EmployeeUSAddress>
        #         <AddressLine1Txt>391 US-206</AddressLine1Txt>
        #         <AddressLine2Txt>Unit 73</AddressLine2Txt>
        #         <CityNm>Hammonton</CityNm>
        #         <StateAbbreviationCd>NJ</StateAbbreviationCd>
        #         <ZIPCd>08037</ZIPCd>
        #       </EmployeeUSAddress>
        #       <WagesAmt>50000</WagesAmt>
        #       <WithholdingAmt>1000</WithholdingAmt>
        #       <SocialSecurityWagesAmt>50000</SocialSecurityWagesAmt>
        #       <SocialSecurityTaxAmt>3100</SocialSecurityTaxAmt>
        #       <MedicareWagesAndTipsAmt>50000</MedicareWagesAndTipsAmt>
        #       <MedicareTaxWithheldAmt>725</MedicareTaxWithheldAmt>
        #       <OtherDeductionsBenefitsGrp>
        #         <Desc>414HSUB</Desc>
        #         <Amt>250</Amt>
        #       </OtherDeductionsBenefitsGrp>
        xml.W2StateLocalTaxGrp do
          xml.W2StateTaxGrp do
            # xml.StateAbbreviationCd
            xml.EmployerStateIdNum w2.employer_state_id_num
            xml.StateWagesAmt w2.state_wages_amount&.round
            xml.StateIncomeTaxAmt w2.state_income_tax_amount&.round
            xml.W2LocalTaxGrp do
              xml.LocalWagesAndTipsAmt w2.local_wages_and_tips_amount&.round
            #   LocalIncomeTaxAmt
              xml.LocalityNm w2.locality_nm
            end
          end
        end
        #       <StandardOrNonStandardCd>S</StandardOrNonStandardCd>
      end
    end
  end
end
