class DuplicateIntakeGuard < SimpleDelegator
  def has_duplicate?
    ClientLoginService.new(:gyr).accessible_intakes.each do |intake|
      return true if DeduplificationService.duplicates(intake, :hashed_primary_ssn).exists?
    end
  end
end
