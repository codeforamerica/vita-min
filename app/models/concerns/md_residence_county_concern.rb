module MdResidenceCountyConcern
  extend ActiveSupport::Concern

  COUNTIES_AND_SUBDIVISIONS = {
    "Allegany" => {
      "Allegany - unincorporated" => "0100",
      "Town Of Barton" => "0101",
      "Bel Air" => "0112",
      "Bowling Green" => "0115",
      "Cresaptown" => "0108",
      "City Of Cumberland" => "0102",
      "Ellerslie" => "0113",
      "City Of Frostburg" => "0103",
      "LaVale" => "0110",
      "Town Of Lonaconing" => "0104",
      "Town Of Luke" => "0105",
      "McCoole" => "0114",
      "Town Of Midland" => "0106",
      "Mt Savage" => "0111",
      "Potomac Park" => "0109",
      "Town Of Westernport" => "0107"
    },
    "Anne Arundel" => {
      "Anne Arundel - unincorporated" => "0200",
      "City Of Annapolis" => "0201",
      "Town Of Highland Beach" => "0203"
    },
    "Baltimore County" => {
      "Baltimore County - unincorporated" => "0300"
    },
    "Baltimore City" => {
      "Baltimore City" => "0400"
    },
    "Calvert" => {
      "Calvert - unincorporated" => "0500",
      "Town Of Chesapeake Beach" => "0501",
      "Town Of North Beach" => "0502"
    },
    "Caroline" => {
      "Caroline - unincorporated" => "0600",
      "Town Of Denton" => "0602",
      "Town Of Federalsburg" => "0603",
      "Town Of Goldsboro" => "0604",
      "Town Of Greensboro" => "0605",
      "Town Of Henderson" => "0611",
      "Town Of Hillsboro" => "0606",
      "Town Of Marydel" => "0607",
      "Town Of Preston" => "0608",
      "Town Of Ridgely" => "0609",
      "Town Of Templeville" => "0610"
    },
    "Carroll" => {
      "Carroll - unincorporated" => "0700",
      "Town Of Hampstead" => "0701",
      "Town Of Manchester" => "0702",
      "Town Of Mt Airy" => "0703",
      "Town Of New Windsor" => "0704",
      "Town Of Sykesville" => "0705",
      "City Of Taneytown" => "0706",
      "Town Of Union Bridge" => "0707",
      "City Of Westminster" => "0709"
    },
    "Cecil" => {
      "Cecil - unincorporated" => "0800",
      "Town Of Cecilton" => "0801",
      "Town Of Charlestown" => "0802",
      "Town Of Chesapeake City" => "0803",
      "Town Of Elkton" => "0804",
      "Town Of North East" => "0805",
      "Town Of Perryville" => "0806",
      "Town Of Port Deposit" => "0807",
      "Town Of Rising Sun" => "0808"
    },
    "Charles" => {
      "Charles - unincorporated" => "0900",
      "Town Of Indian Head" => "0901",
      "Town Of La Plata" => "0902",
      "Port Tobacco Village" => "0903"
    },
    "Dorchester" => {
      "Dorchester - unincorporated" => "1000",
      "Town Of Brookview" => "1008",
      "City Of Cambridge" => "1001",
      "Town Of Church Creek" => "1002",
      "Town Of East New Market" => "1003",
      "Town Of Eldorado" => "1007",
      "Town Of Galestown" => "1009",
      "Town Of Hurlock" => "1004",
      "Town Of Secretary" => "1005",
      "Town Of Vienna" => "1006"
    },
    "Frederick" => {
      "Frederick - unincorporated" => "1100",
      "City Of Brunswick" => "1101",
      "Town Of Burkittsville" => "1102",
      "Town Of Emmitsburg" => "1103",
      "City Of Frederick" => "1104",
      "Town Of Middletown" => "1106",
      "Town Of Mt Airy" => "1114",
      "Town Of Myersville" => "1107",
      "Town Of New Market" => "1108",
      "Village Of Rosemont" => "1113",
      "Town Of Thurmont" => "1110",
      "Town Of Walkersville" => "1111",
      "Town Of Woodsboro" => "1112"
    },
    "Garrett" => {
      "Garrett - unincorporated" => "1200",
      "Town Of Accident" => "1201",
      "Town Of Deer Park" => "1203",
      "Town Of Friendsville" => "1204",
      "Town Of Grantsville" => "1205",
      "Town Of Kitzmiller" => "1206",
      "Town Of Loch Lynn Heights" => "1207",
      "Town Of Mountain Lake Park" => "1208",
      "Town Of Oakland" => "1209"
    },
    "Harford" => {
      "Harford - unincorporated" => "1300",
      "City Of Aberdeen" => "1301",
      "Town Of Bel Air" => "1302",
      "City Of Havre De Grace" => "1303"
    },
    "Howard" => {
      "Howard - unincorporated" => "1400"
    },
    "Kent" => {
      "Kent - unincorporated" => "1500",
      "Town Of Betterton" => "1501",
      "Town Of Chestertown" => "1502",
      "Town Of Galena" => "1503",
      "Town Of Millington" => "1504",
      "Town Of Rock Hall" => "1505"
    },
    "Montgomery" => {
      "Montgomery - unincorporated" => "1600",
      "Town Of Barnesville" => "1601",
      "Town Of Brookeville" => "1602",
      "Town Of Chevy Chase" => "1615",
      "Section 3 Of The Village Of Chevy Chase" => "1614",
      "Section 5 Of The Village Of Chevy Chase" => "1616",
      "Town Of Chevy Chase View" => "1617",
      "Chevy Chase Village" => "1613",
      "Village Of Drummond" => "1623",
      "Village Of Friendship Heights" => "1621",
      "City Of Gaithersburg" => "1603",
      "Town Of Garrett Park" => "1604",
      "Town Of Glen Echo" => "1605",
      "Town Of Kensington" => "1606",
      "Town Of Laytonsville" => "1607",
      "Village Of Martins Additions" => "1622",
      "Village Of North Chevy Chase" => "1618",
      "Town Of Oakmont" => "1619",
      "Town Of Poolesville" => "1608",
      "City Of Rockville" => "1609",
      "Town Of Somerset" => "1610",
      "City Of Takoma Park" => "1611",
      "Town Of Washington Grove" => "1612"
    },
    "Prince George's" => {
      "Prince george's - unincorporated" => "1700",
      "Town Of Berwyn Heights" => "1701",
      "Town Of Bladensburg" => "1702",
      "City Of Bowie" => "1704",
      "Town Of Brentwood" => "1705",
      "Town Of Capitol Heights" => "1706",
      "Town Of Cheverly" => "1707",
      "City Of College Park" => "1725",
      "Town Of Colmar Manor" => "1708",
      "Town Of Cottage City" => "1709",
      "City Of District Heights" => "1710",
      "Town Of Eagle Harbor" => "1711",
      "Town Of Edmonston" => "1712",
      "Town Of Fairmount Heights" => "1713",
      "Town Of Forest Heights" => "1728",
      "City Of Glenarden" => "1730",
      "City Of Greenbelt" => "1714",
      "City Of Hyattsville" => "1715",
      "Town Of Landover Hills" => "1726",
      "City Of Laurel" => "1716",
      "Town Of Morningside" => "1727",
      "City Of Mt Rainier" => "1717",
      "City Of New Carrollton" => "1729",
      "Town Of North Brentwood" => "1718",
      "Town Of Riverdale Park" => "1720",
      "City Of Seat Pleasant" => "1721",
      "Town Of University Park" => "1723",
      "Town Of Upper Marlboro" => "1724"
    },
    "Queen Anne's" => {
      "Queen Anne's - unincorporated" => "1800",
      "Town Of Barclay" => "1805",
      "Town Of Centreville" => "1801",
      "Town Of Church Hill" => "1802",
      "Town Of Millington" => "1808",
      "Town Of Queen Anne" => "1807",
      "Town Of Queenstown" => "1803",
      "Town Of Sudlersville" => "1804",
      "Town Of Templeville" => "1806"
    },
    "St. Mary's" => {
      "St. Mary's - unincorporated" => "1900",
      "Town Of Leonardtown" => "1902"
    },
    "Somerset" => {
      "Somerset - unincorporated" => "2000",
      "City Of Crisfield" => "2001",
      "Town Of Princess Anne" => "2002"
    },
    "Talbot" => {
      "Talbot - unincorporated" => "2100",
      "Town Of Easton" => "2101",
      "Town Of Oxford" => "2102",
      "Town Of Queen Anne" => "2107",
      "Town Of St Michaels" => "2103",
      "Town Of Trappe" => "2104"
    },
    "Washington" => {
      "Washington - unincorporated" => "2200",
      "Town Of Boonsboro" => "2201",
      "Town Of Clearspring" => "2202",
      "Town Of Funkstown" => "2203",
      "City Of Hagerstown" => "2204",
      "Town Of Hancock" => "2205",
      "Town Of Keedysville" => "2206",
      "Town Of Sharpsburg" => "2207",
      "Town Of Smithsburg" => "2208",
      "Town Of Williamsport" => "2209"
    },
    "Wicomico" => {
      "Wicomico - unincorporated" => "2300",
      "Town Of Delmar" => "2301",
      "City Of Fruitland" => "2308",
      "Town Of Hebron" => "2302",
      "Town Of Mardela Springs" => "2303",
      "Town Of Pittsville" => "2307",
      "City Of Salisbury" => "2304",
      "Town Of Sharptown" => "2305",
      "Town Of Willards" => "2306"
    },
    "Worcester" => {
      "Worcester - unincorporated" => "2400",
      "Town Of Berlin" => "2401",
      "Town Of Ocean City" => "2402",
      "Pocomoke City" => "2403",
      "Town Of Snow Hill" => "2404"
    }
  }

  def counties_for_select
    COUNTIES_AND_SUBDIVISIONS.keys
  end

  def counties_and_subdivisions_array
    COUNTIES_AND_SUBDIVISIONS.to_a
  end
end