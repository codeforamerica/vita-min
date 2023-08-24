class ArchiveHadStudentInFamilyColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :intake_archives, :had_student_in_family, :integer
  end
end
