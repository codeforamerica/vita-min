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
        attributes_hash = Hash[(0...attributes_array.size).zip attributes_array]
        @intake.update!(dependents_attributes: attributes_hash)
      end
    end
  end
end