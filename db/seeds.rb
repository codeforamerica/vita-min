unless Rails.env.production?
  Seeder.new.run

  addresses = [
    { address: "1901 W Faria Ln, Phoenix, AZ, 85023", state_code: "AZ" },
    { address: "530 S Dobson Rd, Mesa, AZ, 85202", state_code: "AZ" },
    { address: "7750 E Balao Dr, Scottsdale, AZ, 85266", state_code: "AZ" },
    { address: "1963 E Apache Blvd, Tempe, AZ, 85281", state_code: "AZ" },
    { address: "2100 S Constellation Way, Gilbert, AZ, 85295", state_code: "AZ" },
    { address: "4407 W Peoria Ave, Glendale, AZ, 85302", state_code: "AZ" },
    { address: "801 W Acadia Dr, Tucson, AZ, 85756", state_code: "AZ" },
    { address: "1400 E Thomas Rd, Phoenix, AZ, 85014", state_code: "AZ" },
    { address: "9301 E Shea Blvd, Scottsdale, AZ, 85260", state_code: "AZ" },
    { address: "1000 E Spence Ave, Tempe, AZ, 85281", state_code: "AZ" },
    { address: "7401 E David Dr, Tucson, AZ, 85730", state_code: "AZ" },
    { address: "150 E Brownsville Flats Rd, Payson, AZ, 85541", state_code: "AZ" },
    { address: "7530 W Wood St, Phoenix, AZ, 85043", state_code: "AZ" },
    { address: "4501 N 112th Dr, Phoenix, AZ, 85037", state_code: "AZ" },
    { address: "2700 S Royal Palm Rd, Apache Junction, AZ, 85119", state_code: "AZ" },
    { address: "1411 W Lisa Ln, Tempe, AZ, 85284", state_code: "AZ" },
    { address: "7100 N 81st Dr, Glendale, AZ, 85303", state_code: "AZ" },
    { address: "37701 N 26th St, Cave Creek, AZ, 85331", state_code: "AZ" },
    { address: "7977 W Wacker Rd, Peoria, AZ, 85381", state_code: "AZ" },
    { address: "3020 E Main St, Mesa, AZ, 85213", state_code: "AZ" },
    { address: "4301 W Maldonado Rd, Laveen, AZ, 85339", state_code: "AZ" },
    { address: "3500 W Willow Ave, Phoenix, AZ, 85029", state_code: "AZ" },
    { address: "39800 N 10th Pl, Scottsdale, AZ, 85262", state_code: "AZ" },
    { address: "700 W Santa Maria St, Tucson, AZ, 85706", state_code: "AZ" },
    { address: "15801 N 39th Pl, Phoenix, AZ, 85032", state_code: "AZ" },
    { address: "1301 N Dakota St, Chandler, AZ, 85225", state_code: "AZ" },
    { address: "2 E Elm Ln, Avondale, AZ, 85323", state_code: "AZ" },
    { address: "12930 W Mandalay Ln, El Mirage, AZ, 85335", state_code: "AZ" },
    { address: "2600 W 20th St, Yuma, AZ, 85364", state_code: "AZ" },
    { address: "7400 W Hearn Rd, Peoria, AZ, 85381", state_code: "AZ" },
    { address: "1201 E Jefferson St, Phoenix, AZ, 85034", state_code: "AZ" },
    { address: "555 W 2nd Ave, Mesa, AZ, 85210", state_code: "AZ" },
    { address: "1269 N Promenade Pkwy, Casa Grande, AZ, 85194", state_code: "AZ" },
    { address: "16427 N Scottsdale Rd, Scottsdale, AZ, 85254", state_code: "AZ" },
    { address: "600 N 347th Ln, Tonopah, AZ, 85354", state_code: "AZ" },
    { address: "701 E Calle Mariachi, Tucson, AZ, 85706", state_code: "AZ" },
    { address: "808 N Revere, Mesa, AZ, 85201", state_code: "AZ" },
    { address: "3601 W Villa Linda Dr, Glendale, AZ, 85310", state_code: "AZ" },
    { address: "3901 W Layton St, Thatcher, AZ, 85552", state_code: "AZ" },
    { address: "9211 Morgan Mountain Rd, Lakeside, AZ, 85929", state_code: "AZ" },
    { address: "2100 S Warriors Run, Cottonwood, AZ, 86326", state_code: "AZ" },
    { address: "901 W Watson Dr, Tempe, AZ, 85283", state_code: "AZ" },
    { address: "200 N Laura Dr, Chandler, AZ, 85225", state_code: "AZ" },
    { address: "1604 E De Bruhl St, Yuma, AZ, 85365", state_code: "AZ" },
    { address: "10300 W Ponderosa Cir, Sun City, AZ, 85373", state_code: "AZ" },
    { address: "19201 W Windsor Ave, Buckeye, AZ, 85396", state_code: "AZ" },
    { address: "2101 S Saint Suzanne Dr, Tucson, AZ, 85713", state_code: "AZ" },
    { address: "700 N Boulder Ridge Rd, Payson, AZ, 85541", state_code: "AZ" },
    { address: "5017 N 16th Ave, Phoenix, AZ, 85015", state_code: "AZ" }
  ]

  addresses.each do |address|
    ChallengeAddress.create!(address)
  end


end

