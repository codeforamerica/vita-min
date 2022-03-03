class SsnItinForm < QuestionsForm
  set_attributes_for :intake, :primary_ssn, :primary_tin_type
  set_attributes_for :confirmation, :primary_ssn_confirmation

  validates_presence_of :primary_tin_type
  validates_presence_of :primary_ssn
  validates :primary_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? primary_tin_type }
  validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin" }

  with_options if: -> { (primary_ssn.present? && primary_ssn.remove("-") != intake.primary_ssn) || primary_ssn_confirmation.present? } do
    validates :primary_ssn, confirmation: true
    validates :primary_ssn_confirmation, presence: true
  end

  def save
    @intake.update(attributes_for(:intake))
  end
end
