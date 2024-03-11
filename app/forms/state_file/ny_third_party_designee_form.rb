module StateFile
  class NyThirdPartyDesigneeForm < QuestionsForm
    set_attributes_for :intake,
                       :confirmed_third_party_designee

    validates :confirmed_third_party_designee, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end