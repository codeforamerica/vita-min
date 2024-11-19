module StateFile
  class NjEitcQualifyingChildForm < QuestionsForm
    set_attributes_for :intake,
                       :claimed_as_eitc_qualifying_child,
                       :spouse_claimed_as_eitc_qualifying_child

    validates :claimed_as_eitc_qualifying_child, presence: true
    validates :spouse_claimed_as_eitc_qualifying_child, presence: true, if: -> { intake.filing_status_mfj? }
    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
