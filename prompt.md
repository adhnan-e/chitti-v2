# Prompt Evaluation & Improvement

This document provides a detailed evaluation of your original prompt and presents an improved, high-precision version tailored for a senior architect.

## Evaluation of Original Prompt

### Strengths
- **Clear Persona**: Defines the architect role correctly.
- **Goal Oriented**: Focuses on "data accuracy" and "zero accounting failures," which is critical for financial apps.
- **Functional Breadth**: Covers the lifecycle of a chitty (create to close) and member management.

### Weaknesses (The "Gaps")
- **Ambiguous Gold Logic**: Doesn't specify if gold pricing is static or dynamic (spot price), which fundamentally changes the ledger logic.
- **Loose Accounting Model**: Mentions "ledger" but doesn't define the **Double Entry** or **Immutable Transaction Store** patterns required for "zero failure."
- **Concurrency & Race Conditions**: In a system with lucky draws and simultaneous payments, race conditions are a high risk not addressed in the prompt.
- **Auditability**: It asks for traceability but doesn't specify an "Audit Log" or "State Snapshotting" mechanism.
- **Slot vs. User**: The distinction between a "Member/User" and a "Slot" (Account Unit) needs more architectural rigor to handle multi-slot scenarios without data duplication.

---

## The Improved Prompt

```markdown
# Prompt: Senior Architect for Chitty Financial System (Zero-Failure)

## Persona
You are a Lead Financial Systems Architect and Senior Flutter Engineer. You specialize in high-integrity fintech applications where data consistency, auditability, and deterministic accounting are non-negotiable.

## Objective
Design and architect a Flutter/Firebase (or Supabase) application for managing "Chitties" (Chit Funds). The system must guarantee zero accounting errors through a transaction-led system and provide 100% traceability for every currency/gold unit.

## Core Domain Logic

### 1. The Multi-Asset Ledger
- **Asset Classes**: Support both Currency (AED/INR) and Gold (Weight-based).
- **Gold Options**: Define options by Type (Coin, Bar), Purity (24k, 22k), and Weight.
- **The "Rule of One"**: Every financial change must originate from a single `Transaction` document. Never update a "TotalPaid" field without a corresponding linked transaction record.

### 2. Slot-Based Participation
- Users are entities; **Slots** are the fundamental accounting units.
- One Member -> Multiple Slots. Each slot has its own lifecycle:
    - `OpeningBalance`
    - `MonthlyEMI` (Calculated based on slot value / duration)
    - `Status`: (Active, Won, Defaulted, Closed)

### 3. The "Winner" Lifecycle (Lucky Draw)
- **Selection**: Deterministic or Random (specify algorithm).
- **Post-Win Logic**: The "Dividend/Discount" logic must be applied atomically.
    - *Example*: Once a slot wins in Month 5, the "Discount" must automatically reduce the `RemainingDues` for Months 6 through N.

## Functional Requirements

### Organizer Ops
- **Chitty Factory**: Configurable duration, start month (handling back-dated ledger entries), and asset weights.
- **Batch Processing**: Tools to advance the Chitty month, which triggers "Current Due" snapshots for all slots.

### Member Transparency
- **Statement of Account (SoA)**: Generate a per-slot ledger showing every payment vs. every discount applied.
- **Payment Verification**: Dual-state payments (Pending -> Verified) to ensure the Organizer has cleared the funds.

## Technical Architecture Expectations

### State Management & Logic
- **Clean Architecture**: Decouple domain logic (interest/discount calculations) from UI.
- **Immutability**: Use `freezed` or similar for models. A transaction, once written, is NEVER edited—only reversed with a counter-transaction.

### Backend & Database (Firebase/Supabase)
- **Atomic Transactions**: Use Database Transactions for adding winners and applying discounts to ensure no slot is skipped or double-counted.
- **Cloud Functions**: Offload heavy month-end processing to server-side logic to prevent client-side data corruption.

### Data Models
- `Chitty`: Rules, Rewards, Timeline.
- `Slot`: The bridge between User and Chitty. Holds the `Balance` snapshot.
- `Transaction`: The source of truth. Type: `PAYMENT`, `DISCOUNT`, `PRIZE_PAYOUT`, `REVERSAL`.

## Specific "Failure Prevention" Challenges to Solve
1. **The Mid-Cycle Joiner**: How do you calculate catch-up payments for a member joining in Month 3 of a 12-month cycle?
2. **Gold Price Volatility**: If the Reward is "10g Gold", does the Organizer store the gold or the cash equivalent at the time of winning?
3. **The "Orphaned" Payment**: Handling payments for a chitty that is closed or suspended.

## Deliverables
- **Entity Relationship Diagram (Mermaid)**.
- **Dart Model definitions** (with JSON serialization logic).
- **Service Layer Mockup** for `PaymentProcessor` and `LuckyDrawManager`.
- **Edge Case Matrix**: A table of 5-10 failure scenarios and their architectural mitigations.

"Make it robust enough for a production banking environment. Focus on the ledger first, the UI second."
```

---

## Implementation Strategy (For You)

To implement this improved prompt successfully:
1. **Start with the Ledger**: Define a `Transaction` collection as your absolute source of truth.
2. **Use Slot Sharding**: Instead of one big `members` map, use a sub-collection of `slots` for better scalability in Firebase.
3. **Deterministic Math**: Use `Decimal` types or store values in cents/milligrams to avoid floating-point errors (e.g., `totalAED = 10050` for 100.50).
