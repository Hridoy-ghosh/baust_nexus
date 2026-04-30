class AppConstants {
  static const String appName = 'BAUST Nexus';
  static const String appTagline = 'Smart Campus Companion';
  static const String universityName = 'Bangladesh Army University of Science and Technology';
  static const String universityLocation = 'Saidpur Cantonment, Nilphamari';
  
  static const String contact1 = '01769675588';
  static const String contact2 = '01769675554';
  static const String contact3 = '01786278922';
  static const String website = 'www.baust.edu.bd';
  
  static const List<Map<String, dynamic>> departments = [
    {'name': 'CSE', 'fullName': 'Computer Science & Engineering', 'icon': '💻', 'totalCredits': 160},
    {'name': 'EEE', 'fullName': 'Electrical & Electronic Engineering', 'icon': '⚡', 'totalCredits': 160},
    {'name': 'ME', 'fullName': 'Mechanical Engineering', 'icon': '⚙️', 'totalCredits': 160},
    {'name': 'IPE', 'fullName': 'Industrial & Production Engineering', 'icon': '🏭', 'totalCredits': 160},
    {'name': 'CE', 'fullName': 'Civil Engineering', 'icon': '🏗️', 'totalCredits': 160},
    {'name': 'ICT', 'fullName': 'Information & Communication Technology', 'icon': '📡', 'totalCredits': 160},
    {'name': 'BBA', 'fullName': 'Bachelor of Business Administration', 'icon': '📊', 'totalCredits': 130},
    {'name': 'AIS', 'fullName': 'Accounting Information Systems', 'icon': '📚', 'totalCredits': 130},
    {'name': 'English', 'fullName': 'BA (Hons) in English', 'icon': '📖', 'totalCredits': 120},
  ];
  
  static const List<Map<String, dynamic>> levels = [
    {'level': 'Level 1', 'terms': ['Term I', 'Term II']},
    {'level': 'Level 2', 'terms': ['Term I', 'Term II']},
    {'level': 'Level 3', 'terms': ['Term I', 'Term II']},
    {'level': 'Level 4', 'terms': ['Term I', 'Term II']},
  ];
  
  static const List<String> designations = ['Lecturer', 'Asst. Professor', 'Professor'];
  
  static const Map<String, String> libraryTimings = {
    'Saturday - Thursday': '8:00 AM - 5:00 PM',
    'Friday': 'Closed',
    'Exam Period': '8:00 AM - 7:00 PM',
  };
  
  static const Map<String, String> libraryInfo = {
    'name': 'BAUST Central Library',
    'location': 'Administration Building, Ground Floor',
    'totalBooks': '25,000+',
    'journals': '100+ National & International',
    'seatingCapacity': '200 Students',
    'digitalResources': 'Available - E-books, Journals, Research Papers',
    'wifi': 'Free WiFi Available',
    'rules': 'Silence must be maintained. ID card is mandatory.',
  };

  static const Map<String, String> dressCode = {
    'male_summer': 'Ash coloured half sleeve shirt (tucked in), Black full pants, Black Oxford shoes & socks',
    'male_winter': 'Ash coloured full sleeve shirt (tucked in), Black full pants, Blue blazer, Black Oxford shoes & socks',
    'female_summer': 'Ash coloured three quarter sleeve Kamiz, White Sallowar & Dopatta, Black shoes & socks',
    'female_winter': 'Ash coloured three quarter sleeve Kamiz, White Sallowar & Dopatta, Blue blazer, Black shoes & socks',
  };

  // Daily Available Items (always available)
  static const List<Map<String, String>> dailyItems = [
    {'name': '☕ Coffee', 'price': '25 Tk'},
    {'name': '🍰 Cake', 'price': '30 Tk'},
    {'name': '🍪 Biscuits', 'price': '15 Tk'},
    {'name': '🥐 Samosa', 'price': '10 Tk'},
    {'name': '🥟 Singara', 'price': '10 Tk'},
    {'name': '🍩 Puri', 'price': '15 Tk'},
    {'name': '🌯 Chicken Roll', 'price': '45 Tk'},
    {'name': '🍔 Burger', 'price': '55 Tk'},
    {'name': '🍕 Pizza Slice', 'price': '60 Tk'},
    {'name': '🥤 Cold Drink', 'price': '25 Tk'},
    {'name': '🧃 Juice', 'price': '30 Tk'},
    {'name': '🍞 Bread Toast', 'price': '20 Tk'},
    {'name': '🥚 Boiled Egg', 'price': '15 Tk'},
    {'name': '🍳 Omelette', 'price': '25 Tk'},
    {'name': '☕ Tea', 'price': '10 Tk'},
  ];

  // Weekly Menu
  static const List<Map<String, dynamic>> cafeteriaMenu = [
    {
      'day': 'Saturday',
      'breakfast': 'Porota, Dal, Sobji, Egg, Tea',
      'breakfastPrice': '45 Tk',
      'lunch': 'Rice, Fish Curry, Dal, Mixed Vegetable, Salad',
      'lunchPrice': '65 Tk',
      'snacks': 'Samosa, Singara, Tea/Coffee',
      'snacksPrice': '25 Tk',
      'special': '🍗 Special Biryani',
      'specialPrice': '120 Tk',
    },
    {
      'day': 'Sunday',
      'breakfast': 'Ruti, Sobji, Egg, Tea',
      'breakfastPrice': '40 Tk',
      'lunch': 'Rice, Beef Curry, Dal, Bharta, Salad',
      'lunchPrice': '80 Tk',
      'snacks': 'Pizza Slice, Juice',
      'snacksPrice': '60 Tk',
      'special': '🍖 Chicken Kebab',
      'specialPrice': '90 Tk',
    },
    {
      'day': 'Monday',
      'breakfast': 'Chapati, Dal, Egg, Tea',
      'breakfastPrice': '35 Tk',
      'lunch': 'Chicken Biryani, Borhani, Salad',
      'lunchPrice': '85 Tk',
      'snacks': 'Burger, Cold Drink',
      'snacksPrice': '55 Tk',
      'special': '🍛 Mutton Rezala',
      'specialPrice': '150 Tk',
    },
    {
      'day': 'Tuesday',
      'breakfast': 'Puri, Chana, Sweet, Tea',
      'breakfastPrice': '45 Tk',
      'lunch': 'Rice, Mutton Curry, Dal, Salad, Firni',
      'lunchPrice': '95 Tk',
      'snacks': 'Cake, Coffee',
      'snacksPrice': '40 Tk',
      'special': '🐟 Fish Fry Platter',
      'specialPrice': '100 Tk',
    },
    {
      'day': 'Wednesday',
      'breakfast': 'Sandwich, Juice, Fruit',
      'breakfastPrice': '55 Tk',
      'lunch': 'Rice, Fish Fry, Dal, Mixed Vegetable, Salad',
      'lunchPrice': '70 Tk',
      'snacks': 'Chicken Roll, Tea',
      'snacksPrice': '45 Tk',
      'special': '🍜 Chowmein Combo',
      'specialPrice': '80 Tk',
    },
    {
      'day': 'Thursday',
      'breakfast': 'Noodles, Egg, Tea/Coffee',
      'breakfastPrice': '45 Tk',
      'lunch': 'Khichuri, Beef Bhuna, Egg, Pickle',
      'lunchPrice': '75 Tk',
      'snacks': 'French Fries, Burger, Cold Drink',
      'snacksPrice': '65 Tk',
      'special': '🍗 BBQ Chicken',
      'specialPrice': '130 Tk',
    },
    {
      'day': 'Friday',
      'breakfast': 'Special Weekend Breakfast',
      'breakfastPrice': '65 Tk',
      'lunch': 'Special Biryani, Kebab, Salad, Dessert',
      'lunchPrice': '110 Tk',
      'snacks': 'Special Snacks Combo',
      'snacksPrice': '75 Tk',
      'special': '🍱 Weekend Special Thali',
      'specialPrice': '200 Tk',
    },
  ];
  
  static const Map<String, String> cafeteriaInfo = {
    'name': 'Miritika Cafeteria',
    'location': 'Ground Floor',
    'openingTime': '8:00 AM',
    'closingTime': '8:00 PM',
    'specialNote': 'Payment kore token nin! Token diye khabar nin! Online order available. Daily special offers!',
    'managerContact': '01769675556',
  };
}