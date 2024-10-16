module MdResidenceCountyConcern
  extend ActiveSupport::Concern

  COUNTIES_AND_SUBDIVISIONS = {
    "Allegany" => {
      "Allegany - unincorporated" => "0100",
      "Town of Barton" => "0101",
      "Bel Air" => "0112",
      "Bowling Green" => "0115",
      "Cresaptown" => "0108",
      "City of Cumberland" => "0102",
      "Ellerslie" => "0113",
      "City of Frostburg" => "0103",
      "LaVale" => "0110",
      "Town of Lonaconing" => "0104",
      "Town of Luke" => "0105",
      "McCoole" => "0114",
      "Town of Midland" => "0106",
      "Mt. Savage" => "0111",
      "Potomac Park" => "0109",
      "Town of Westernport" => "0107"
    },
    "Anne Arundel" => {
      "Anne Arundel - unincorporated" => "0200",
      "City of Annapolis" => "0201",
      "Town of Highland Beach" => "0203"
    },
    "Baltimore County" =>
      {"Baltimore County - unincorporated" => "0300"},
    "Baltimore City" =>
      {"Baltimore City - unincorporated" => "0400"},
    "Calvert" => {
      "Calvert - unincorporated" => "0500",
      "Town of Chesapeake Beach" => "0501",
      "Town of North Beach" => "0502"
    },
    "Caroline" => {
      "Caroline - unincorporated" => "0600",
      "Town of Denton" => "0602",
      "Town of Federalsburg" => "0603",
      "Town of Goldsboro" => "0604",
      "Town of Greensboro" => "0605",
      "Town of Henderson" => "0611",
      "Town of Hillsboro" => "0606",
      "Town of Marydel" => "0607",
      "Town of Preston" => "0608",
      "Town of Ridgely" => "0609",
      "Town of Templeville" => "0610"
    },
    "Carroll" => {
      "Carroll - unincorporated" => "0700",
      "Town of Hampstead" => "0701",
      "Town of Manchester" => "0702",
      "Town of Mt. Airy" => "0703",
      "Town of New Windsor" => "0704",
      "Town of Sykesville" => "0705",
      "City of Taneytown" => "0706",
      "Town of Union Bridge" => "0707",
      "City of Westminster" => "0709"
    },
    "Cecil" => {
      "Cecil - unincorporated" => "0800",
      "Town of Cecilton" => "0801",
      "Town of Charlestown" => "0802",
      "Town of Chesapeake City" => "0803",
      "Town of Elkton" => "0804",
      "Town of North East" => "0805",
      "Town of Perryville" => "0806",
      "Town of Port Deposit" => "0807",
      "Town of Rising Sun" => "0808"
    },
    "Charles" => {
      "Charles - unincorporated" => "0900",
      "Town of Indian Head" => "0901",
      "Town of La Plata" => "0902",
      "Port Tobacco Village" => "0903"
    },
    "Dorchester" => {
      "Dorchester - unincorporated" => "1000",
      "Town of Brookview" => "1008",
      "City of Cambridge" => "1001",
      "Town of Church Creek" => "1002",
      "Town of East New Market" => "1003",
      "Town of Eldorado" => "1007",
      "Town of Galestown" => "1009",
      "Town of Hurlock" => "1004",
      "Town of Secretary" => "1005",
      "Town of Vienna" => "1006"
    },
    "Frederick" => {
      "Frederick - unincorporated" => "1100",
      "City of Brunswick" => "1101",
      "Town of Burkittsville" => "1102",
      "Town of Emmitsburg" => "1103",
      "City of Frederick" => "1104",
      "Town of Middletown" => "1106",
      "Town of Mt. Airy" => "1114",
      "Town of Myersville" => "1107",
      "Town of New Market" => "1108",
      "Village of Rosemont" => "1113",
      "Town of Thurmont" => "1110",
      "Town of Walkersville" => "1111",
      "Town of Woodsboro" => "1112"
    },
    "Garrett" => {
      "Garrett - unincorporated" => "1200",
      "Town of Accident" => "1201",
      "Town of Deer Park" => "1203",
      "Town of Friendsville" => "1204",
      "Town of Grantsville" => "1205",
      "Town of Kitzmiller" => "1206",
      "Town of Loch Lynn Heights" => "1207",
      "Town of Mountain Lake Park" => "1208",
      "Town of Oakland" => "1209"
    },
    "Harford" => {
      "Harford - unincorporated" => "1300",
      "City of Aberdeen" => "1301",
      "Town of Bel Air" => "1302",
      "City of Havre de Grace" => "1303"
    },
    "Howard" => {
      "Howard - unincorporated" => "1400"
    },
    "Kent" => {
      "Kent - unincorporated" => "1500",
      "Town of Betterton" => "1501",
      "Town of Chestertown" => "1502",
      "Town of Galena" => "1503",
      "Town of Millington" => "1504",
      "Town of Rock Hall" => "1505"
    },
    "Montgomery" => {
      "Montgomery - unincorporated" => "1600",
      "Town of Barnesville" => "1601",
      "Town of Brookeville" => "1602",
      "Town of Chevy Chase" => "1615",
      "Section 3 of the Village of Chevy Chase" => "1614",
      "Section 5 of the Village of Chevy Chase" => "1616",
      "Town of Chevy Chase View" => "1617",
      "Chevy Chase Village" => "1613",
      "Village of Drummond" => "1623",
      "Village of Friendship Heights" => "1621",
      "City of Gaithersburg" => "1603",
      "Town of Garrett Park" => "1604",
      "Town of Glen Echo" => "1605",
      "Town of Kensington" => "1606",
      "Town of Laytonsville" => "1607",
      "Village of Martin's Additions" => "1622",
      "Village of North Chevy Chase" => "1618",
      "Town of Oakmont" => "1619",
      "Town of Poolesville" => "1608",
      "City of Rockville" => "1609",
      "Town of Somerset" => "1610",
      "City of Takoma Park" => "1611",
      "Town of Washington Grove" => "1612"
    },
    "Prince george's" => {
      "Prince george's - unincorporated" => "1700",
      "Town of Berwyn Heights" => "1701",
      "Town of Bladensburg" => "1702",
      "City of Bowie" => "1704",
      "Town of Brentwood" => "1705",
      "Town of Capitol Heights" => "1706",
      "Town of Cheverly" => "1707",
      "City of College Park" => "1725",
      "Town of Colmar Manor" => "1708",
      "Town of Cottage City" => "1709",
      "City of District Heights" => "1710",
      "Town of Eagle Harbor" => "1711",
      "Town of Edmonston" => "1712",
      "Town of Fairmount Heights" => "1713",
      "Town of Forest Heights" => "1728",
      "City of Glenarden" => "1730",
      "City of Greenbelt" => "1714",
      "City of Hyattsville" => "1715",
      "Town of Landover Hills" => "1726",
      "City of Laurel" => "1716",
      "Town of Morningside" => "1727",
      "City of Mt. Rainier" => "1717",
      "City of New Carrollton" => "1729",
      "Town of North Brentwood" => "1718",
      "Town of Riverdale Park" => "1720",
      "City of Seat Pleasant" => "1721",
      "Town of University Park" => "1723",
      "Town of Upper Marlboro" => "1724"
    },
    "Queen anne's" => {
      "Queen anne's - unincorporated" => "1800",
      "Town of Barclay" => "1805",
      "Town of Centreville" => "1801",
      "Town of Church Hill" => "1802",
      "Town of Millington" => "1808",
      "Town of Queen Anne" => "1807",
      "Town of Queenstown" => "1803",
      "Town of Sudlersville" => "1804",
      "Town of Templeville" => "1806"
    },
    "St. mary's" => {
      "St. mary's - unincorporated" => "1900",
      "Town of Leonardtown" => "1902"
    },
    "Somerset" => {
      "Somerset - unincorporated" => "2000",
      "City of Crisfield" => "2001",
      "Town of Princess Anne" => "2002"
    },
    "Talbot" => {
      "Talbot - unincorporated" => "2100",
      "Town of Easton" => "2101",
      "Town of Oxford" => "2102",
      "Town of Queen Anne" => "2105",
      "Town of St. Michaels" => "2103",
      "Town of Trappe" => "2104"
    },
    "Washington" => {
      "Washington - unincorporated" => "2200",
      "Town of Boonsboro" => "2201",
      "Town of Clearspring" => "2202",
      "Town of Funkstown" => "2203",
      "City of Hagerstown" => "2204",
      "Town of Hancock" => "2205",
      "Town of Keedysville" => "2206",
      "Town of Sharpsburg" => "2207",
      "Town of Smithsburg" => "2208",
      "Town of Williamsport" => "2209"
    },
    "Wicomico" => {
      "Wicomico - unincorporated" => "2300",
      "Town of Delmar" => "2301",
      "City of Fruitland" => "2308",
      "Town of Hebron" => "2302",
      "Town of Mardela Springs" => "2303",
      "Town of Pittsville" => "2307",
      "City of Salisbury" => "2304",
      "Town of Sharptown" => "2305",
      "Town of Willards" => "2306"
    },
    "Worcester" => {
      "Worcester - unincorporated" => "2400",
      "Town of Berlin" => "2401",
      "Town of Ocean City" => "2402",
      "Pocomoke City" => "2403",
      "Town of Snow Hill" => "2404"
    }
  }

  def counties_for_select
    COUNTIES_AND_SUBDIVISIONS.keys
  end

  def counties_and_subdivisions_array
    COUNTIES_AND_SUBDIVISIONS.to_a
  end
end