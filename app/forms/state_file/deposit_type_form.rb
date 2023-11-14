module StateFile
  class DepositTypeForm < QuestionsForm
    set_attributes_for :intake, :deposit_type

    validates :deposit_type, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end

