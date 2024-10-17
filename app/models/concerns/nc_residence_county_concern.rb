# Handles the bits of the North Carolina state file intake that deals with the
# county.
module NcResidenceCountyConcern
  extend ActiveSupport::Concern

  COUNTIES = {
    "001" => "Alamance", "002" => "Alexander", "003" => "Alleghany", "004" => "Anson",
    "005" => "Ashe", "006" => "Avery", "007" => "Beaufort", "008" => "Bertie",
    "009" => "Bladen", "010" => "Brunswick", "011" => "Buncombe", "012" => "Burke",
    "013" => "Cabarrus", "014" => "Caldwell", "015" => "Camden", "016" => "Carteret",
    "017" => "Caswell", "018" => "Catawba", "019" => "Chatham", "020" => "Cherokee",
    "021" => "Chowan", "022" => "Clay", "023" => "Cleveland", "024" => "Columbus",
    "025" => "Craven", "026" => "Cumberland", "027" => "Currituck", "028" => "Dare",
    "029" => "Davidson", "030" => "Davie", "031" => "Duplin", "032" => "Durham",
    "033" => "Edgecombe", "034" => "Forsyth", "035" => "Franklin", "036" => "Gaston",
    "037" => "Gates", "038" => "Graham", "039" => "Granville", "040" => "Greene",
    "041" => "Guilford", "042" => "Halifax", "043" => "Harnett", "044" => "Haywood",
    "045" => "Henderson", "046" => "Hertford", "047" => "Hoke", "048" => "Hyde",
    "049" => "Iredell", "050" => "Jackson", "051" => "Johnston", "052" => "Jones",
    "053" => "Lee", "054" => "Lenoir", "055" => "Lincoln", "056" => "Macon",
    "057" => "Madison", "058" => "Martin", "059" => "McDowell", "060" => "Mecklenburg",
    "061" => "Mitchell", "062" => "Montgomery", "063" => "Moore", "064" => "Nash",
    "065" => "New Hanover", "066" => "Northampton", "067" => "Onslow", "068" => "Orange",
    "069" => "Pamlico", "070" => "Pasquotank", "071" => "Pender", "072" => "Perquimans",
    "073" => "Person", "074" => "Pitt", "075" => "Polk", "076" => "Randolph",
    "077" => "Richmond", "078" => "Robeson", "079" => "Rockingham", "080" => "Rowan",
    "081" => "Rutherford", "082" => "Sampson", "e083" => "Scotland", "084" => "Stanly",
    "085" => "Stokes", "086" => "Surry", "087" => "Swain", "088" => "Transylvania",
    "089" => "Tyrrell", "090" => "Union", "091" => "Vance", "092" => "Wake",
    "093" => "Warren", "094" => "Washington", "095" => "Watauga", "096" => "Wayne",
    "097" => "Wilkes", "098" => "Wilson", "099" => "Yadkin", "100" => "Yancey",
    # The XML doesn't appear to like this one, which makes sense because if they
    # are out of state they can't file their taxes with us. Still, I've included
    # it for posterity
    # "101" => "Out-of-State"
  }

  # Convenient hash to see both code and name
  def residence_county_hash
    {
      county_code: residence_county,
      county_name: residence_county_name
    }
  end

  # Convenience method to map county to human readable name
  def residence_county_name
    COUNTIES.fetch(residence_county, 'unfilled')
  end

  def counties_for_select
    COUNTIES.invert
  end
end
