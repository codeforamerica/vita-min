module StateFile
  class NjGubernatorialElectionsForm < QuestionsForm
    set_attributes_for :intake,
                       :primary_contribution_gubernatorial_elections,
                       :spouse_contribution_gubernatorial_elections
    
    validates :primary_contribution_gubernatorial_elections, presence: true
    validates :spouse_contribution_gubernatorial_elections, presence: true, if: -> { intake.filing_status_mfj? }
    
    def save
      @intake.update(attributes_for(:intake))
    end

  end
end