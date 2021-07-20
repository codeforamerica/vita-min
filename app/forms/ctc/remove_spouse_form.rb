module Ctc
  class RemoveSpouseForm < QuestionsForm
    def save
      @intake.update!({
        spouse_first_name: nil,
        spouse_middle_initial: nil,
        spouse_last_name: nil,
        spouse_tin_type: nil,
        spouse_ssn: nil,
        spouse_veteran: nil,
        spouse_birth_date: nil
      })
    end
  end
end
