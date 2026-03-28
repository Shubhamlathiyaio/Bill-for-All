# Core Features & Modules

## 1. Universal Billing Engine
At the heart of **Bill For All** is a highly adaptable billing engine capable of handling varied tax structures, product varieties, service line items, and discounts. 

## 2. Dynamic Adaptive Interface
- **Context-Aware Modules:** The app dynamically loads feature modules based on the user's configuration. 
- **Role-Based Views:** Even within a single business, an owner sees a different UI (dashboards, analytics) than a cashier (POS screen).

## 3. PDF Invoice Generation & Printing
A critical feature explicitly requested is the ability to generate PDF invoices directly within the app.
- **On-Device Generation:** Using Flutter's PDF libraries, invoices are drawn natively on the device ensuring they work offline.
- **Direct Printing:** Integration with thermal receipt printers (Bluetooth/USB) and standard A4 network printers. Users can "directly print those" without leaving the app.

## 4. Cross-Platform Environment
- **Mobile First, PC Ready:** The app provides a seamless experience whether a shop owner is using a smartphone on the go or a desktop PC at a checkout counter. The UI must be highly responsive to accommodate diverse form factors.
- **Storage Flexibility Selection:** A core setup feature allowing the user to select where their data lives: `[ ] Local Mobile`, `[ ] Local PC`, `[ ] Global Online Sync`.
