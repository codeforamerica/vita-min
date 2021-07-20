module Ctc
  class RemoveSpouseForm < QuestionsForm
    set_attributes_for :intake,
                       :spouse_first_name,
                       :spouse_middle_initial,
                       :spouse_last_name,
                       :spouse_tin_type,
                       :spouse_ssn,
                       :spouse_veteran,
                       :spouse_birth_date

    def save
      @intake.update!(remove_spouse_attr)
    end

    def remove_spouse_attr
      {
        spouse_first_name: nil,
        spouse_middle_initial: nil,
        spouse_last_name: nil,
        spouse_tin_type: nil,
        spouse_ssn: nil,
        spouse_veteran: nil,
        spouse_birth_date: nil
      }
    end
  end
end
