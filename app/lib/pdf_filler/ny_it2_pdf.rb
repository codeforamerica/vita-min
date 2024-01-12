module PdfFiller
  class NyIt2Pdf
    include PdfHelper

    def source_pdf_name
      "it2-TY2023"
    end

    def nys_form_type
      "102"
    end

    def initialize(submission, kwargs)
      @submission = submission
      @kwargs = kwargs
    end

    def hash_for_pdf
      w2 = @kwargs[:w2]
      answers = {
        'Box_a' => w2.EmployeeSSN,
        'Box_b' => w2.EmployerEIN,
        'Box_c1' => w2.EmployerName,
        'Box_c2' => w2.AddressLine1Txt,
        'Box_c3_city' => w2.City,
        'Box_c3_state' => w2.State,
        'Box_c3_zip' => w2.ZIP,
        'Box_c3_county' => 'United States',
        'Box_1' => w2.WagesAmt,
        'Box_8' => w2.AllocatedTipsAmt,
        'Box_10' => w2.DependentCareBenefitsAmt,
        'Box_11' => w2.NonqualifiedPlansAmt,
        'Box_13b' => map_box_answers(w2.RetirementPlanInd),
        'Box_13c' => map_box_answers(w2.ThirdPartySickPayInd),
        'Box_16a' => w2.StateWagesAmt,
        'Box_17a' => w2.StateIncomeTaxAmt,
        'Box_18a' => w2.LocalWagesAndTipsAmt,
        'Box_19a' => w2.LocalIncomeTaxAmt,
        'Box_20a' => w2.LocalityNm,
      }
      w2.w2_box12.each_with_index do |box12, index|
        break if index >= 4
        answers["12#{('a'..'d').to_a[index]}_code"] = box12[:code]
        answers["Box_12#{('a'..'d').to_a[index]}"] = box12[:value]
      end
      w2.w2_box14.each_with_index do |box14, index|
        break if index >= 4
        answers["14#{('a'..'d').to_a[index]}_description"] = box14[:other_description]
        answers["Box_14#{('a'..'d').to_a[index]}"] = box14[:other_amount]
      end
      answers
    end

    private

    def map_box_answers(value)
      value == 'X' ? 'Yes' : 'Off'
    end
  end
end
