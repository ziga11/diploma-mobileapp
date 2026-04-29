# Recruitment Mobile Application (Frontend)

A cross-platform Flutter application designed to guide candidates through the recruitment and onboarding process.

## 📋 Overview
This app provides a transparent, centralized hub for job seekers. Candidates can view their application status, see their specific job obligations, and manage documentation (contracts, IDs, payslips) directly from their mobile device.

## 🛠 Tech Stack
* **Framework:** Flutter
* **Language:** Dart
* **Architecture:** Clean Architecture (Presentation, Application, Domain, Data layers)
* **Push Notifications:** Firebase Cloud Messaging (FCM)

## ✨ Key Features
* **Multilingual Engine:** Full localization for Slovenian, English, and Bosnian, using `ValueListenable` for instant, non-blocking language swaps.
* **Document Capture & Upload:** Native integration with the camera and file picker for uploading required documentation.
* **Passwordless Authentication:** Uses email-based tokens and App Links for a secure, low-friction login experience.
* **Interactive Request System:** A chat-like interface for submitting specific requests (e.g., tax forms) with attachment support.

## Previews
### ER Diagrams
**Messages**
![ER Diagram](/assets/readme/er_message.svg)
**Obligations**
![ER Diagram](/assets/readme/er_obligation.svg)
**Other**
![ER Diagram](/assets/readme/er_other.svg)

### Mobile Demo
<div align="center">
  <video src="https://github.com/user-attachments/assets/a0115bfd-a068-4d74-aa12-22be183e15c5" width="100%" controls muted>
  </video>
</div>
