class DirectFileJsonData

  def initialize(json)
    @json = JSON.parse(json || "{}")
  end

  def primary_filer
    @json["filers"]&.detect { |filer| filer["isPrimaryFiler"] }
  end

  def spouse_filer
    @json["filers"]&.detect { |filer| !filer["isPrimaryFiler"] }
  end

  def first_name(person)
    person && person["firstName"]
  end

  def primary_first_name
    first_name(primary_filer)
  end

  def spouse_first_name
    first_name(spouse_filer)
  end

  def middle_initial(person)
    person && person["middleInitial"]
  end

  def primary_middle_initial
    middle_initial(primary_filer)
  end

  def spouse_middle_initial
    middle_initial(spouse_filer)
  end

  def last_name(person)
    person && person["lastName"]
  end

  def primary_last_name
    last_name(primary_filer)
  end

  def spouse_last_name
    last_name(spouse_filer)
  end

  def dob(person)
    person && person["dateOfBirth"] && Date.parse(person["dateOfBirth"])
  end

  def primary_dob
    dob(primary_filer)
  end

  def spouse_dob
    dob(spouse_filer)
  end

  def dependents
    @json["familyAndHousehold"]
  end

  def find_matching_json_dependent(dependent)
    return nil unless dependents.respond_to?(:find)

    dependents.find do |json_dependent|
      next unless json_dependent.present?

      json_dependent["tin"]&.tr("-", "") == dependent.ssn
    end
  end
end