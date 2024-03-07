module StateFile
  class NyThirdPartyDesigneeForm < QuestionsForm
    set_attributes_for :intake,
                       :confirm_third_party_designee

    validates :confirm_third_party_designee, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end