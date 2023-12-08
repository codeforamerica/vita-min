module PdfFiller
  class NyIt2Pdf
    include PdfHelper

    def source_pdf_name
      "it2-TY2023"
    end

    def initialize(submission, kwargs: {})
      @submission = submission
      @kwargs = kwargs
    end

    def hash_for_pdf
      w2 = @kwargs[:w2]
      answers = {
        'Box_a' => w2.employee_ssn,
        'Box_b' => w2.employer_ein,
        'Box_c1' => w2.employer_name,
        'Box_c2' => w2.employer_street_address,
        'Box_c3_city' => w2.employer_city,
        'Box_c3_state' => w2.employer_state,
        'Box_c3_zip' => w2.employer_zip_code,
        'Box_c3_county' => 'USA', #TODO check if other countries allowed
        'Box_1' => w2.wages_amount,
        'Box_8' => w2.box8_allocated_tips,
        'Box_10' => w2.box10_dependent_care_benefits,
        'Box_11' => w2.box11_nonqualified_plans,
        'Box_12a' => w2.box12a_value,
        '12a_code' => w2.box12a_code,
        'Box_12b' => w2.box12b_value,
        '12b_code' => w2.box12b_code,
        'Box_12c' => w2.box12c_value,
        '12c_code' => w2.box12c_code,
        'Box_12d' => w2.box12d_value,
        '12d_code' => w2.box12d_code,
        'Box_13b' => map_box_answers(w2.box13_retirement_plan),
        'Box_13c' => map_box_answers(w2.box13_third_party_sick_pay),
        'Box_16a' => w2.w2_state_fields_group.box16_state_wages,
        'Box_17a' => w2.w2_state_fields_group.box17_state_income_tax,
        'Box_18a' => w2.w2_state_fields_group.box18_local_wages,
        'Box_19a' => w2.w2_state_fields_group.box19_local_income_tax,
        'Box_20a' => w2.w2_state_fields_group.box20_locality_name,
      }
      w2.w2_box14.each_with_index do |box14, index|
        break if index >= 4
        answers["14#{('a'..'d').to_a[index]}_description"] = box14.other_description
        answers["Box_14#{('a'..'d').to_a[index]}"] = box14.other_amount
      end
      answers
    end

    private
    def map_box_answers(value)
      value == 'X' ? 'Yes' : 'Off'
    end
  end
end
