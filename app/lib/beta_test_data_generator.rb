# This is used by the beta_test_client factory to create fake clients on demo for beta testing

class BetaTestDataGenerator
  FIRST_NAMES = [
    "Logan", "Justin", "Gabriel", "Jose", "Austin", "Kevin", "Elijah", "Caleb", "Robert", "Thomas", "Jordan",
    "Cameron", "Jack", "Hunter", "Jackson", "Angel", "Isaiah", "Evan", "Isaac", "Luke", "Mason", "Jayden", "Jason", "Gavin",
    "Aaron", "Connor", "Aiden", "Aidan", "Kyle", "Juan", "Charles", "Luis", "Adam", "Lucas", "Brian", "Eric", "Adrian",
    "Nathaniel", "Sean", "Alex", "Carlos", "Bryan", "Ian", "Owen", "Jesus", "Landon", "Julian", "Chase", "Cole", "Diego",
    "Jeremiah", "Steven", "Sebastian", "Xavier", "Timothy", "Carter", "Wyatt", "Brayden", "Blake", "Hayden", "Devin",
    "Cody", "Richard", "Seth", "Dominic", "Jaden", "Antonio", "Miguel", "Liam", "Patrick", "Carson", "Jesse", "Tristan",
    "Alejandro", "Henry", "Victor", "Trevor", "Bryce", "Jake", "Riley", "Colin", "Jared", "Jeremy", "Mark", "Caden",
    "Garrett", "Parker", "Marcus", "Vincent", "Kaleb", "Kaden", "Brady", "Colton", "Kenneth", "Joel", "Oscar", "Josiah",
    "Jorge", "Ashton", "Cooper", "Tanner", "Eduardo", "Paul", "Edward", "Ivan", "Preston", "Maxwell", "Alan", "Levi",
    "Stephen", "Grant", "Nicolas", "Dakota", "Omar", "Alexis", "George", "Eli", "Collin", "Spencer", "Gage", "Max", "Ricardo",
    "Cristian", "Derek", "Micah", "Brody", "Francisco", "Nolan", "Ayden", "Dalton", "Shane", "Peter", "Damian", "Jeffrey",
    "Brendan", "Travis", "Fernando", "Peyton", "Conner", "Andres", "Javier", "Giovanni", "Shawn", "Braden", "Jonah",
    "Bradley", "Cesar", "Emmanuel", "Manuel", "Edgar", "Mario", "Erik", "Edwin", "Johnathan", "Devon", "Erick", "Wesley",
    "Oliver", "Trenton", "Hector", "Malachi", "Jalen", "Raymond", "Gregory", "Abraham", "Elias", "Leonardo", "Sergio",
    "Donovan", "Colby", "Marco", "Bryson", "Martin", "Emily", "Madison", "Emma", "Olivia", "Hannah", "Abigail", "Isabella",
    "Samantha", "Elizabeth", "Ashley", "Alexis", "Sarah", "Sophia", "Alyssa", "Grace", "Ava", "Taylor", "Brianna", "Lauren",
    "Chloe", "Natalie", "Kayla", "Jessica", "Anna", "Victoria", "Mia", "Hailey", "Sydney", "Jasmine", "Julia", "Morgan",
    "Destiny", "Rachel", "Ella", "Kaitlyn", "Megan", "Katherine", "Savannah", "Jennifer", "Alexandra", "Allison",
    "Haley", "Maria", "Kaylee", "Lily", "Makayla", "Brooke", "Nicole", "Mackenzie", "Addison", "Stephanie", "Lillian",
    "Andrea", "Faith", "Zoe", "Kimberly", "Madeline", "Alexa", "Katelyn", "Gabriella", "Gabrielle", "Trinity", "Amanda",
    "Kylie", "Mary", "Paige", "Riley", "Leah", "Jenna", "Sara", "Rebecca", "Michelle", "Sofia", "Vanessa", "Jordan",
    "Angelina", "Caroline", "Avery", "Audrey", "Evelyn", "Maya", "Claire", "Autumn", "Jocelyn", "Ariana", "Nevaeh",
    "Arianna", "Jada", "Bailey", "Brooklyn", "Aaliyah", "Amber", "Isabel", "Mariah", "Danielle", "Melanie", "Sierra",
    "Erin", "Amelia", "Molly", "Isabelle", "Madelyn", "Melissa", "Jacqueline", "Marissa", "Angela", "Shelby", "Leslie",
    "Katie", "Jade", "Catherine", "Diana", "Aubrey", "Mya", "Amy", "Briana", "Sophie", "Gabriela", "Breanna", "Gianna",
    "Kennedy", "Gracie", "Peyton", "Adriana", "Christina", "Courtney", "Daniela", "Lydia", "Kathryn", "Valeria", "Layla",
    "Alexandria", "Natalia", "Angel", "Laura", "Charlotte", "Margaret", "Cheyenne", "Miranda", "Mikayla", "Naomi",
    "Kelsey", "Payton", "Ana", "Alicia", "Jillian", "Daisy", "Ashlyn", "Sabrina", "Caitlin", "Summer",
    "Ruby", "Rylee", "Valerie", "Skylar", "Lindsey", "Kelly", "Genesis", "Zoey", "Eva", "Sadie", "Alexia", "Cassidy",
    "Kylee", "Kendall", "Jordyn", "Kate", "Jayla", "Karen", "Tiffany", "Cassandra", "Juliana", "Reagan", "Caitlyn",
    "Giselle", "Serenity", "Alondra", "Lucy", "Bianca", "Kiara", "Crystal", "Erica", "Angelica", "Hope", "Chelsea",
    "Alana", "Liliana", "Brittany", "Camila", "Makenzie", "Lilly", "Veronica", "Abby", "Jazmin", "Adrianna", "Delaney",
    "Karina", "Ellie", "Jasmin"]

  LAST_NAMES = [
    "Alfalfa", "Apple", "Apricot", "Artichoke", "Asparagus", "Avocado", "Almond",
    "Banana", "Bean", "Beans", "Beets", "Blackberry", "Blueberry", "Boysenberry", "Broccoli", "Basil",
    "Cabbage", "Cantaloupe", "Carrots", "Cassava", "Cauliflower", "Celery", "Chayote", "Cherimoya", "Cherry", "Coconut", "Collards", "Corn", "Cranberry", "Cucumber",
    "Date", "Dill", "Daikon", "Dandelion Greens", "Delicata", "Dragonfruit",
    "Eggplant", "Escarole", "Endive", "Epazote",
    "Fennel", "Fig", "Fenugreek",
    "Garlic", "Gooseberry", "Grapefruit", "Grape", "Green Bean", "Green Onion", "Guava", "Galangal", "Ginger",
    "Honeydew", "Habanero", "Hazelnut", "Hibiscus", "Horseradish",
    "Ilama", "Imbé", "Icaco",
    "Jicama", "Jujube", "Jalapeño", "Jitomate",
    "Kale", "Kiwi", "Kohlrabi", "Kumquat",
    "Leek", "Lemons", "Lettuce", "Lima Bean", "Lime", "Longan", "Loquat", "Lychee", "Lemongrass",
    "Mandarin", "Mango", "Mulberry", "Mushroom", "Mangosteen", "Marjoram", "Maple", "Matcha", "Mustard", "Mustard-Greens", "Mint",
    "Nectarines", "Nopales", "Nutmeg", "Nigella",
    "Okra", "Onion", "Orange", "Oregano",
    "Papaya", "Parsnip", "Passionfruit", "Peach", "Pear", "Pea", "Peas", "Pepper", "Persimmon", "Pineapple", "Plantain", "Plum", "Pomegranate", "Potato", "Prickly Pear", "Prune", "Pomelo", "Pumpkin", "Prickly Pear",
    "Quince",
    "Radicchio", "Radish", "Raisin", "Raspberry", "Rhubarb", "Romaine", "Rutabaga", "Rosemary",
    "Shallot", "Snow-Pea", "Spinach", "Sprouts", "Squash", "Strawberry", "String Bean", "Sweet-Potato", "Serrano", "Sesame",
    "Tangelo", "Tangerine", "Tomatillo", "Tomato", "Turnip", "Thyme", "Tea", "Tamarind",
    "Ube", "Uva",
    "Vidalia", "Verdolaga", "Vanilla",
    "Water Chestnut", "Watercress", "Watermelon", "Waxed Bean", "Wasabi", "Walnut",
    "Xocota", "Ximenia",
    "Yam", "Yucca",
    "Zucchini",
  ]

  STATUSES_AFTER_OPEN = TaxReturnStatus::STATUSES.select do |_, value|
    value >= TaxReturnStatus::STATUSES[:intake_ready]
  end.keys.freeze

  def self.get_name
    first_name = FIRST_NAMES.sample
    last_name = LAST_NAMES.select { |last| last[0] == first_name[0] }.sample
    return [first_name, last_name]
  end

  def self.get_status_open_or_later

  end

  def self.make_clients_for_user(user, all_possible_assignees, count)
    clients = FactoryBot.create_list :beta_test_client, count, vita_partner: user.accessible_vita_partners.first
    clients.each do |client|
      client.tax_returns.each do |tax_return|
        tax_return.status = STATUSES_AFTER_OPEN.sample
        case rand(10)
        when 0..4
          tax_return.assigned_user = user
        when 5
          # assign to a random other user
          tax_return.assigned_user = all_possible_assignees.order(Arel.sql("RANDOM()")).first
        end
        tax_return.save
      end
    end
  end
end
