class StateFileBaseIntake < ApplicationRecord
  self.abstract_class = true

  enum filing_status: { single: 1, married_filing_jointly: 2, married_filing_separately: 3, head_of_household: 4, qualifying_widow: 5 }, _prefix: :filing_status
  enum claimed_as_dep: { yes: 1, no: 2 }, _prefix: :claimed_as_dep
  has_one_attached :submission_pdf

  has_many :dependents, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileDependent', inverse_of: :intake, dependent: :destroy
  has_many :efile_submissions, -> { order(created_at: :asc) }, as: :data_source, class_name: 'EfileSubmission', inverse_of: :data_source, dependent: :destroy

  def primary
    Person.new(self, :primary)
  end

  class Person
    attr_reader :first_name
    attr_reader :last_name
    attr_reader :birth_date
    attr_reader :ssn

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        @first_name = intake.primary_first_name
        @last_name = intake.primary_last_name
        @middle_initial = intake.primary_middle_initial
        @birth_date = intake.primary_dob
        @ssn = intake.primary_ssn
      end
    end
  end
end
