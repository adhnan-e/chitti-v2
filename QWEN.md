# Chitti - Chit Fund Management System

## Project Overview

**Chitti** is a Flutter-based mobile application for managing Chit Funds (also known as "Chitties") - a traditional savings and credit system popular in South Asia. The application provides a zero-failure accounting system built on Firebase Realtime Database.

### Core Purpose
- Enable organizers to create and manage chit funds with configurable duration, slots, and gold-backed rewards
- Allow members to track payments, view ledgers, and participate in lucky draws
- Support both currency-based (AED/INR) and gold-weight-based chit funds
- Ensure 100% traceability through an immutable transaction ledger

### Technology Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase Realtime Database, Firebase Authentication, Firebase Storage
- **State Management**: Provider
- **Code Generation**: Freezed (immutable models), JSON Serializable
- **Key Dependencies**:
  - `firebase_core`, `firebase_database`, `firebase_auth`, `firebase_storage`
  - `provider` - State management
  - `freezed_annotation`, `json_annotation` - Immutable data models
  - `google_fonts`, `fl_chart` - UI components
  - `intl` - Internationalization and currency formatting
  - `image_picker`, `file_picker` - Document uploads

## Architecture

### Directory Structure
```
lib/
├── core/
│   ├── design/          # Theme, UI components, design system
│   ├── domain/          # Core domain enums and business rules
│   └── models/          # Freezed immutable data models
├── features/            # Feature modules (empty - legacy structure)
├── screens/             # All UI screens (procedural architecture)
├── services/            # Business logic and Firebase operations
├── utils/               # Utility functions (currency, formatting)
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

### Core Domain Models

| Model | Description |
|-------|-------------|
| `Chitty` | A chit fund configuration: duration, gold options, max slots, status |
| `Slot` | **The fundamental accounting unit** - a member's position in a chitty |
| `Transaction` | **Single Source of Truth** - immutable record of every financial change |
| `User` | Member/organizer profile |
| `Winner` | Lucky draw winner record with discount details |
| `GoldOption` | Gold configuration (type, purity, weight, price) |
| `EMI Schedule` | Payment schedule calculations |

### Key Architectural Principles

#### 1. Rule of One
Every financial change MUST originate from a single `Transaction` document. Never update balance fields without a corresponding transaction record.

#### 2. Slot-Based Accounting
- Users are entities; **Slots** are the accounting units
- One user can have multiple slots in the same chitty
- Each slot has independent lifecycle: `active` → `won` → `closed`

#### 3. Cents-Based Storage
All monetary values are stored in cents (smallest currency unit) to avoid floating-point errors:
```dart
// Example: AED 100.50 stored as 10050 cents
int amountInCents = 10050;
double amount = CurrencyUtils.fromCents(amountInCents); // 100.50
```

#### 4. Dual-State Payments
Transactions flow through: `pending` → `verified` (or `rejected`)

#### 5. Immutability
Transactions are NEVER edited. Errors are corrected via reversal transactions.

## Building and Running

### Prerequisites
- Flutter SDK 3.8.1+
- Firebase project configured
- Android Studio / VS Code with Flutter extensions

### Setup

1. **Install dependencies**:
```bash
flutter pub get
```

2. **Configure Firebase**:
- Ensure `google-services.json` exists in `android/app/`
- Ensure `firebase_options.dart` is generated

3. **Run the app**:
```bash
flutter run
```

### Build Commands

| Command | Description |
|---------|-------------|
| `flutter run` | Run on connected device/emulator |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter build web` | Build for web (hosted at `alpha-chitti`) |
| `flutter analyze` | Run static analysis |
| `flutter test` | Run unit/widget tests |

### Code Generation

After modifying any `@freezed` or `@JsonSerializable` models:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Firebase Configuration

### Database Structure
```
/users/{userId}           - User profiles
/chittis/{chittiId}       - Chitty configurations
  /members/{slotId}       - Slot details with balance sub-object
  /winners/{monthKey}     - Monthly winners
  /transactionIndex/{slotId}/{txnId} - Transaction lookup index
/transactions/{txnId}     - Global transaction ledger
/lucky_draws/{winnerId}   - Global winner history
/payments/{paymentId}     - Legacy payment records
/app_settings             - Currency, chitti naming format
```

### Security Rules
Currently configured for open access during development (`".read": true, ".write": true`). **Production requires proper authentication rules.**

## Key Services

| Service | Responsibility |
|---------|---------------|
| `TransactionService` | Core accounting - record payments, verify, reverse |
| `LuckyDrawManager` | Winner selection (random/deterministic/weighted) |
| `DatabaseService` | Firebase CRUD operations |
| `AuthService` | User authentication |
| `ChittiService` | Chitty lifecycle management |
| `GoldHandoverService` | Gold settlement and handover tracking |
| `BalanceCalculator` | Slot balance computations |
| `ReceiptService` | Receipt generation |

## Transaction Types

| Type | Effect | Description |
|------|--------|-------------|
| `payment` | Credit | Member pays EMI |
| `discount` | Credit | Winner discount applied |
| `prizePayout` | Debit | Prize money disbursed |
| `reversal` | Opposite | Undo a transaction |
| `openingBalance` | Debit | Mid-cycle joiner catch-up |
| `adjustment` | Either | Admin corrections |
| `goldHandover` | Debit | Gold physically delivered |
| `settlementPayment` | Credit | Post-handover settlement |

## Development Conventions

### Coding Style
- **Null Safety**: Full null safety enabled
- **Immutability**: All models use `freezed` for immutability
- **Type Safety**: Strong typing with extension methods for serialization
- **Error Handling**: Try-catch with descriptive error messages

### Testing Practices
- Tests located in `/test` directory
- Widget tests for UI components
- Unit tests for services (mock Firebase)
- Run tests: `flutter test`

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Screens**: `*_screen.dart` (e.g., `login_screen.dart`)
- **Services**: `*_service.dart` (e.g., `auth_service.dart`)

### Git Workflow
- Feature branches: `feature/description`
- Bug fixes: `fix/description`
- Commits follow conventional commit format

## Common Operations

### Create a Chitty
```dart
await chittiService.createChitti(
  name: 'Chitti 1',
  duration: 12,
  startMonth: '2025-01',
  goldOptions: [...],
  maxSlots: 20,
  paymentDay: 1,
  luckyDrawDay: 15,
);
```

### Record a Payment
```dart
await transactionService.recordPayment(
  slotId: slot.id,
  chittiId: chitti.id,
  amountInCents: 50000, // AED 500.00
  monthKey: '2025-01',
  paymentMethod: PaymentMethod.cash,
);
```

### Select Lucky Draw Winner
```dart
final result = await luckyDrawManager.selectWinner(
  chittiId: chitti.id,
  month: '2025-03',
  algorithm: DrawAlgorithm.random,
);
```

## Edge Cases Handled

1. **Mid-Cycle Joiner**: Opening balance transaction for catch-up payments
2. **Winner Discount Cascade**: Automatic discount application to remaining months
3. **Payment Reversal**: Counter-transaction instead of editing
4. **Gold Price Volatility**: Price locked at chitty creation
5. **Multiple Slots per User**: Slot-based accounting prevents data duplication
6. **Rounding Errors**: Cents-based storage with remainder in first month

## Known Issues / TODOs

- [ ] Security rules need production hardening
- [ ] Unit test coverage is minimal (see `test_output.txt` for failing tests)
- [ ] Cloud Functions for server-side month-end processing (currently client-side)
- [ ] Audit logging for compliance
- [ ] Multi-currency support (currently AED-focused)

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Realtime Database](https://firebase.google.com/docs/database)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Provider Package](https://pub.dev/packages/provider)
