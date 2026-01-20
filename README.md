# ☠️ Toxic AI App

AI-powered toxicity analyzer for messages. Analyze how toxic your texts are!

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 📱 Screenshots

<p align="center">
  <img width="486" height="864" alt="image" src="https://github.com/user-attachments/assets/d242c7ae-b045-404b-ad7c-4fbdf16f57b5" />

  <img width="490" height="866" alt="image" src="https://github.com/user-attachments/assets/b91aaf13-cc93-40c6-8f80-04e3cdd17a53" />

  <img width="482" height="860" alt="image" src="https://github.com/user-attachments/assets/ac13cab3-c95d-47e3-a654-b635d66b8330" />

  <img width="479" height="866" alt="image" src="https://github.com/user-attachments/assets/ed74e7cc-d236-46f6-8fa4-a912763e81aa" />

  <img width="487" height="859" alt="image" src="https://github.com/user-attachments/assets/3ebf5c62-b4d6-41d0-ad0d-e63811986b4c" />

  <img width="484" height="862" alt="image" src="https://github.com/user-attachments/assets/6380a9fd-ca3f-44a0-b744-4a61e361198c" />

  <img width="482" height="858" alt="image" src="https://github.com/user-attachments/assets/39f8da7a-ebc8-4e28-918d-fe18df379b9f" />

  <img width="480" height="864" alt="image" src="https://github.com/user-attachments/assets/e2bfba4f-5415-4cf2-aaf3-7a46555c5c40" />

  <img width="480" height="861" alt="image" src="https://github.com/user-attachments/assets/cdd6397e-5cec-440d-9d75-d56c1896369a" />

  <img width="475" height="864" alt="image" src="https://github.com/user-attachments/assets/ad660d25-d306-48eb-b005-f6dfd8e54bdc" />

</p>

## ✨ Features

- 🔍 **AI Toxicity Analysis** - Analyze any message for toxicity level
- 📊 **Toxicity Score** - Get a percentage score (0-100%)
- 😤 **Passive-Aggressive Detection** - Detect hidden hostility
- 🎭 **Gaslighting Detection** - Identify manipulative language
- 🏆 **Daily Challenges** - Compete with others for the most toxic message
- 📈 **Leaderboard** - See top toxic messages of the day/week
- 🔄 **Message Transform** - Convert toxic messages to friendly ones
- 📤 **Share Results** - Share your toxicity score as an image
- 🌍 **Multi-language** - English & Turkish support

## 🎯 Categories

Analyze messages from different sources:

| Category | Emoji |
|----------|-------|
| Ex | 💔 |
| Boss | 👔 |
| Parent | 👨‍👩‍👧 |
| Friend | 👥 |
| Colleague | 💼 |
| Sibling | 👫 |

## 🛠️ Tech Stack

- **Framework:** Flutter
- **Backend:** Firebase Firestore
- **AI:** Groq API (LLaMA 3.3 70B)
- **State Management:** setState
- **Local Storage:** SharedPreferences

## 📦 Installation

### Prerequisites

- Flutter SDK (>=3.4.3)
- Firebase project
- Groq API key

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/toxic-ai-app.git
cd toxic-ai-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a Firebase project
   - Enable Firestore Database
   - Add your Firebase config to `main.dart`

4. **Add Groq API Key**
   - Get a free API key from [Groq](https://console.groq.com)
   - Add it to `lib/services/ai_service.dart`

5. **Run the app**
```bash
flutter run
```

## 🔥 Firebase Setup

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /leaderboard/{document} {
      allow read, write: if true;
    }
  }
}
```

## 📁 Project Structure

```
lib/
├── main.dart
├── models/
│   ├── analysis_result.dart
│   ├── category_model.dart
│   └── leaderboard_entry.dart
├── screens/
│   ├── home_screen.dart
│   ├── category_screen.dart
│   ├── compare_screen.dart
│   ├── leaderboard_screen.dart
│   ├── language_screen.dart
│   ├── share_card_screen.dart
│   └── transform_screen.dart
└── services/
    ├── ai_service.dart
    ├── app_localizations.dart
    ├── language_service.dart
    └── leaderboard_service.dart
```

## 🎮 How It Works

1. **Choose a category** (Ex, Boss, Parent, etc.)
2. **Paste or type a message** you received
3. **Get AI analysis** with:
   - Toxicity percentage
   - Passive-aggressive level
   - Gaslighting detection
   - Savage AI comment
4. **Submit to leaderboard** to compete with others
5. **Share your results** on social media

## 🏆 Daily Challenges

| Day | Challenge |
|-----|-----------|
| Monday | 💔 Ex Day |
| Tuesday | 👔 Boss Day |
| Wednesday | ☠️ Maximum Toxicity |
| Thursday | 👨‍👩‍👧 Family Day |
| Friday | 😇 Innocence Day |
| Saturday | 👥 Friend Group |
| Sunday | 🏆 Champion Day |

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.



## 👨‍💻 Author

Made with Nazli's love☠️ and Flutter

---

⭐ **Star this repo if you found it useful!**
