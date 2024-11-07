module StateFile
  class IdPermanentBuildingFundForm < QuestionsForm
    set_attributes_for :intake, :received_id_public_assistance

    validates :received_id_public_assistance, inclusion: { in: %w[yes no], message: :blank }


    def save
      attributes_to_save = attributes_for(:intake)
      @intake.update!(attributes_to_save)
    end
  end
end
