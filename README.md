💰 Expense Tracker - Flutter Mobile App
https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white
https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white

📱 Overview
A beautiful and intuitive Expense Tracker mobile application built with Flutter that helps users manage their daily expenses, track spending by categories, and maintain financial discipline.

✨ Features
🎯 Core Features
➕ Add Expenses with title, amount, category, and date

📊 Category-wise Tracking (Food, Transport, Shopping, etc.)

🗑️ Swipe to Delete expenses with intuitive gestures

💰 Real-time Total Calculation automatic expense summing

📱 Beautiful UI with Material Design 3

🏷️ Expense Categories
🍕 Food

🚗 Transport

🛍️ Shopping

🎬 Entertainment

📄 Bills

🏥 Health

💼 Other

📊 Visual Features
Category Icons for easy recognition

Date Formatting in user-friendly format

Color-coded amounts for better visibility

Empty state illustrations with helpful prompts

🛠️ Technology Stack
Framework: Flutter 3.0+

Language: Dart

State Management: setState (Simple & Effective)

Storage: Shared Preferences (Local Data Persistence)

UI: Material Design 3

📁 Project Structure
text
expense_tracker/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── expense_tracker.dart  # Main home screen
│   │   └── add_expense_screen.dart # Add expense form
│   ├── models/
│   │   └── expense_model.dart    # Data model
│   └── services/
│       └── storage_service.dart  # Local storage handling
├── pubspec.yaml                  # Dependencies & metadata
└── README.md
🚀 Installation & Setup
Prerequisites
Flutter SDK 3.0 or higher

Dart SDK

Android Studio / VS Code

Android Emulator or Physical Device

Step 1: Clone the Repository
bash
git clone https://github.com/yourusername/expense-tracker-flutter.git
cd expense-tracker-flutter
Step 2: Install Dependencies
bash
flutter pub get
Step 3: Run the Application
bash
# For Android
flutter run

# For iOS (if on macOS)
flutter run -d ios
Step 4: Build for Release
bash
# Build APK for Android
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build for iOS (macOS only)
flutter build ios --release
📋 Dependencies
Add these to your pubspec.yaml:

yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
🎨 UI Components
Main Screen (expense_tracker.dart)
Total Expenses Card: Shows sum of all expenses

Expenses List: Scrollable list with swipe to delete

Floating Action Button: Quick access to add new expenses

Empty State: Helpful illustration when no expenses

Add Expense Screen (add_expense_screen.dart)
Text Fields: Title and amount input

Dropdown: Category selection

Date Picker: Calendar integration

Validation: Input error handling

🔧 Code Architecture
Data Model (expense_model.dart)
dart
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  
  // Constructor, toMap(), fromMap() methods
}
Storage Service (storage_service.dart)
Save/Load Expenses using SharedPreferences

JSON Serialization for data persistence

Budget Management capabilities

📱 Screenshots
Main Features:
Home Screen - Overview of all expenses

Add Expense - Form with validation

Category Icons - Visual category representation

Swipe Gestures - Intuitive delete functionality

🎯 Usage Guide
Adding an Expense:
Tap the + floating button

Enter expense title

Input amount (numeric only)

Select category from dropdown

Choose date using date picker

Tap "Add Expense"

Managing Expenses:
View: Scroll through the list

Delete: Swipe left on any expense item

Track: Monitor total spending in header card

Categories & Icons:
🍕 Food - Restaurant icon

🚗 Transport - Car icon

🛍️ Shopping - Shopping bag icon

🎬 Entertainment - Movie icon

📄 Bills - Receipt icon

🏥 Health - Hospital icon

💼 Other - Money icon

🔄 State Management
The app uses Flutter's built-in setState for state management, making it:

Simple and easy to understand

Lightweight for this scale of application

Performant for the feature set

💾 Data Persistence
Local Storage:
Shared Preferences for simple key-value storage

JSON Serialization for complex objects

Automatic Save/Load on app start/stop

Data Structure:
json
{
  "expenses": [
    {
      "id": "123456789",
      "title": "Groceries",
      "amount": 45.50,
      "date": "2024-01-15",
      "category": "Food"
    }
  ]
}
🚀 Future Enhancements
Planned Features:
Budget Setting per category

Expense Analytics with charts

Export Data to CSV/PDF

Dark/Light Theme toggle

Recurring Expenses setup

Search & Filter functionality

Backup to Cloud (Google Drive/iCloud)

Technical Improvements:
Bloc/Cubit for state management

SQLite for complex queries

Unit & Widget Tests

Internationalization (i18n)

🐛 Troubleshooting
Common Issues:
"Package not found" error:

bash
flutter clean
flutter pub get
Build fails:

bash
flutter doctor
flutter pub deps
Storage not working:

Check Shared Preferences permissions

Verify JSON encoding/decoding

Debugging:
bash
flutter run --debug
flutter analyze
flutter test
📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

🤝 Contributing
Fork the repository

Create your feature branch (git checkout -b feature/AmazingFeature)

Commit your changes (git commit -m 'Add some AmazingFeature')

Push to the branch (git push origin feature/AmazingFeature)

Open a Pull Request

🙏 Acknowledgments
Flutter Team for the amazing framework

Material Design for UI components

Icons8 for category icons inspiration

📞 Support
If you have any questions or need help with setup:

Open an Issue on GitHub

Check Flutter Documentation

Review code comments for implementation details

Start tracking your expenses today and take control of your finances! 💰📊

Built with ❤️ using Flutter & Dart
