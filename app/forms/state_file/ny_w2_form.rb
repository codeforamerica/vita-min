module StateFile
  class NyW2Form < QuestionsForm
    attr_accessor :w2s_attributes

    def initialize(intake = nil, params = nil)
      super
      assign_nested_attributes
    end

    # thinking we might not need this
    def self.from_intake(intake)
      # binding.pry
      # puts "From intake..."
      # Derive params from intake...
    end

    #def dependents
    #  @intake.dependents.select(&:ask_senior_questions?)
    #end

    def save
      assign_nested_attributes
      @w2s.each(&:save!)
    end

    # assigning the @w2s variable does seem a little janky to me but i was in get-the-test-to-pass mode
    def assign_nested_attributes
      if @intake.state_file_w2s.present?
        @intake.state_file_w2s.each do |w2|
          matching_attrs = w2s_attributes.find do |_, attrs|
            w2.w2_index == attrs[:w2_index]
          end
          w2.assign_attributes(matching_attrs[1])
        end
        @w2s = @intake.state_file_w2s
      else
        @w2s = w2s_attributes.map do |_, attrs|
          StateFileW2.new(state_file_intake: @intake, **attrs)
        end
      end
    end

    # thinking we shuold put validations on the model level (StateFileW2) and call valid on each instance
    def valid?
      super
      # super && dependents.all? { |d| d.valid?(:az_senior_form) }
    end
  end
end