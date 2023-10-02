class StateFileBaseIntake < ApplicationRecord
  self.abstract_class = true

  enum claimed_as_dep: { yes: 1, no: 2 }, _prefix: :claimed_as_dep
  has_one_attached :submission_pdf

  has_many :dependents, -> { order(created_at: :asc) }, as: :intake, class_name: 'StateFileDependent', inverse_of: :intake, dependent: :destroy
  has_many :efile_submissions, -> { order(created_at: :asc) }, as: :data_source, class_name: 'EfileSubmission', inverse_of: :data_source, dependent: :destroy

  delegate :tax_return_year, :filing_status, to: :direct_file_data

  def direct_file_data
    @direct_file_data ||= DirectFileData.new(raw_direct_file_data)
  end

  def filing_status
    {
      1 => :single,
      2 => :married_filing_jointly,
      3 => :married_filing_separately,
      4 => :head_of_household,
      5 => :qualifying_widow,
    }[direct_file_data&.filing_status]
  end

  def primary
    Person.new(self, :primary)
  end

  def spouse
    Person.new(self, :spouse)
  end

  class Person
    attr_reader :first_name
    attr_reader :middle_initial
    attr_reader :last_name
    attr_reader :birth_date
    attr_reader :ssn

    def initialize(intake, primary_or_spouse)
      @primary_or_spouse = primary_or_spouse
      if primary_or_spouse == :primary
        # TODO TODO TODO -- pull off intake.direct_file_data or somewhere TBD
        @first_name = "Testy"
        @last_name = "Testerson"
        @middle_initial = "T"

        @birth_date = intake.direct_file_data.primary_dob
        @ssn = intake.direct_file_data.primary_ssn
      else
        # TODO
        # @first_name = intake.spouse_first_name
        # @last_name = intake.spouse_last_name
        # @middle_initial = intake.spouse_middle_initial
        # @birth_date = intake.spouse_dob
        # @ssn = intake.spouse_ssn
      end
    end
  end
end
