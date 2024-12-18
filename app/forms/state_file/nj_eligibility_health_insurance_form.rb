module StateFile
  class NjEligibilityHealthInsuranceForm < QuestionsForm
    set_attributes_for :intake, :eligibility_all_members_health_insurance
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    validates :eligibility_all_members_health_insurance, presence: true

    def save
      @intake.update(attributes_for(:intake))
      if @intake.eligibility_all_members_health_insurance_no?
        @intake.update!(dependents_attributes: dependents_attributes.to_h)
      else
        attributes_array = intake.dependents.map do |dependent|
           { id: dependent.id, nj_did_not_have_health_insurance: 'no' }
        end
        @intake.update!(dependents_attributes: attributes_array)
      end
    end
  end
end