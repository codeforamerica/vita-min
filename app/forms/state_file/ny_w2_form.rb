module StateFile
  class NyW2Form < QuestionsForm
    attr_accessor :w2s
    attr_reader :intake
    #has_many :state_file_w2s
    #set_attributes_for

    def initialize(intake = nil, params = nil)
      super
      if params.present?
        puts "Write from params"
        # Write params to existing w2s...
      end
    end

    def self.from_intake(intake)
      binding.pry
      puts "From intake..."
      # Derive params from intake...
    end


    #def dependents
    #  @intake.dependents.select(&:ask_senior_questions?)
    #end

    def save
      puts "Would update intake here..."
      #@intake.update!({ dependents_attributes: dependents_attributes.to_h })
    end

    def valid?
      super
      # super && dependents.all? { |d| d.valid?(:az_senior_form) }
    end
  end
end