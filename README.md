# CraftBridge (Softi) — Flutter + Firebase Edition

Full conversion of the CraftBridge / Softi React + Firebase marketplace into a modular Flutter application connected to Cloud Firestore and Firebase Authentication.

## Included Modules
- **Firebase Setup (`lib/firebase_options.dart`, `lib/services/firebase_service.dart`)**: Pre-wired to project `gen-lang-client-0440786332` and Firestore database `ai-studio-803e4a0a-f3df-4f3d-b652-d7c9fd5489c6`.
- **Auth & Role Onboarding (`lib/screens/auth/auth_onboarding_screen.dart`)**: Supports Google Sign-In, Email/Password sign-in & registration, and Homeowner (`client`) vs. Service Partner (`provider`) portal selection.
- **Customer Portal (`lib/screens/client/`)**:
  - Explore verified trade vendors (`Electrical`, `Plumbing`, `Appliance Repair`, `Cleaning`) with 10–15 km Haversine geo-filtering and interactive Spatial Proximity Radar (`lib/widgets/radius_radar_widget.dart`).
  - Post new service requests (`ServiceRequestFormSheet`) with atomic batch writes to `/serviceRequests/{id}` and PII-isolated `/serviceRequests/{id}/contactDetails/private`.
  - Real-time job tracking (`open` -> `accepted` -> `in_progress` -> `completed`) and Escrow Payment settlement (`PaymentCheckoutSheet`).
  - Real-time Practical Training Certificate Verifier (`CertificateVerifierCard`).
- **Vendor Partner Portal (`lib/screens/provider/`)**:
  - Mandatory Practical Lab credential registration (`ProviderRegistrationSheet`) writing to `/providers/{uid}` and `/certificates/{certId}` in `pending` state.
  - Live 10–15 km Dispatch Radar to inspect and accept open jobs, unlock masked customer phone/address upon acceptance, and advance job status to completion.
  - Escrow earnings & payout ledger.
- **Admin Verification Queue (`lib/screens/admin/admin_verification_screen.dart`)**:
  - Approve or revoke vendor certificates (`verified` / `revoked`) and one-tap seed initial Softi Academy vendors and sample requests.

## Quick Start
1. Ensure you have Flutter SDK installed (`flutter doctor`).
2. Inside `craftbridge_flutter/`, run:
   ```bash
   flutter create . --platforms=android,ios,web
   flutter pub get
   flutterfire configure --project=gen-lang-client-0440786332
   flutter run
   ```
   *(Note: `flutter create .` generates the platform `android/`, `ios/`, and `web/` runner folders around `lib/` and `assets/`.)*
