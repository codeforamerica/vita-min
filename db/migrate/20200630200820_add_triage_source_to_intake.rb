class AddTriageSourceToIntake < ActiveRecord::Migration[6.0]
  def change
    add_reference :intakes, :triage_source, polymorphic: true, index: true
  end
end
