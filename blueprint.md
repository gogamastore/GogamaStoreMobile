# Application Blueprint

## 1. Overview

This document outlines the core structure, design principles, and technical architecture of the **Gogama Store** application. It serves as a single source of truth for development, ensuring consistency and clarity across all features. The app is a complete e-commerce solution for resellers, featuring product browsing, cart management, a comprehensive checkout process, and order history.

## 2. Style & Design

- **Theme:** Modern, clean, and professional, utilizing Material 3 design principles.
- **Color Scheme:** A palette centered around a primary color (e.g., deep purple), with distinct schemes for light and dark modes to ensure clarity and visual comfort.
- **Typography:** Uses the `google_fonts` package for a consistent and readable text hierarchy. Key styles include `Oswald` for titles and `Roboto` or `Open Sans` for body text.
- **Iconography:** Employs Material Design icons for intuitive navigation and actions.
- **Layout:** Responsive design that adapts to various screen sizes, ensuring a seamless experience on both mobile and web platforms. Key layouts include card-based grids for products and clean, organized forms for user input.

## 3. Features Implemented

- **User Authentication:** Full login/logout functionality using Firebase Auth.
- **Product Catalog:**
  - Fetches and displays a list of all products from Firestore.
  - Displays a dedicated list of trending products.
  - A detail screen for each product.
- **Shopping Cart:**
  - Add, update, and remove items from the cart.
  - The cart is persistent and tied to the user's account.
  - Real-time total calculation.
- **Checkout Process:**
  - **Address Management:**
    - Users can select from a list of previously saved addresses.
    - The form automatically populates when a saved address is chosen.
    - Users can also enter a new shipping address manually.
  - **Shipping Options:** Users can choose between courier delivery or in-store pickup.
  - **Payment Methods:**
    - **Bank Transfer:** Displays a complete list of all company bank accounts from Firestore for manual transfer.
    - **COD (Cash on Delivery):** Available only for in-store pickup.
  - **Order Summary:** A complete review of items, subtotal, shipping costs, and grand total.
  - **Place Order:** Submits the order to Firestore, updates product stock, and clears the user's cart.
- **Order History:** A dedicated screen where users can view a list of their past orders.
- **Profile Screen:** A placeholder for future user profile management.
- **Routing:** Advanced navigation handled by `go_router`, including auth-based redirects and a corrected `push/pop` navigation flow for a proper back-stack.
- **State Management:** Uses the `provider` package for robust and scalable state management, particularly for authentication, cart, and checkout.

## 4. Firestore Data Structure

This section details the schema for the primary Firestore collections used in the application.

### `user` Collection

Stores user profile information and nested sub-collections for user-specific data.

- **Document ID:** `userId` (from Firebase Auth)

**Sub-collections:**
- `addresses`: Stores saved shipping addresses for a user.
- `cart`: Stores the items in the user's shopping cart.

#### `addresses` Sub-Collection
- **Document ID:** `addressId` (auto-generated)
| Field | Type | Description |
|---|---|---|
| `name` | `string` | Recipient's name. |
| `phone` | `string` | Recipient's phone number. |
| `address`| `string` | The main street address. |
| `city` | `string` | City. |
| `postal_code` or `postalCode`|`string` | Postal code. The app robustly handles both `snake_case` and `camelCase`. |
| `isDefault`| `boolean`| Indicates if it's the primary address. |

### `products` Collection

Contains all available products for sale.

- **Document ID:** `productId` (auto-generated)
| Field | Type | Description |
|---|---|---|
| `name` | `string` | Product name. |
| `description`| `string` | Detailed product description. |
| `price` | `number` | The price of the product. |
| `imageUrl` | `string` | URL to the product image. |
| `stock` | `number` | Current stock quantity. |
| `category` | `string` | Product category. |

### `bank_accounts` Collection

Stores all bank account information for the "Bank Transfer" payment method.

- **Document ID:** `accountId` (auto-generated)
| Field | Type | Description |
|---|---|---|
| `bankName` | `string` | The name of the bank (e.g., "Bank BRI"). |
| `accountHolder`|`string` | The name of the account holder. |
| `accountNumber`| `string` | The bank account number. |

### `orders` Collection

This collection stores all customer order information.

- **Document ID:** `orderId` (auto-generated)
| Field | Type | Description |
|---|---|---|
| `customerId` | `string` | The UID of the user who placed the order. |
| `customerDetails`| `map` | Contains name, address, and phone number for shipping. |
| `products` | `array` | An array of maps, each representing a product in the order. |
| `subtotal` | `number` | Total cost before shipping. |
| `shippingFee`| `number` | The cost of shipping. |
| `total` | `number` | The final grand total. |
| `shippingMethod`| `string` | The chosen shipping method. |
| `paymentMethod`| `string` | The chosen payment method. |
| `paymentProofUrl`| `string` | URL of the uploaded payment proof image. |
| `status` | `string` | The current status of the order (e.g., 'Pending', 'Processing'). |
| `date` | `timestamp`| The date and time the order was placed. |

## 5. Current Task: Initial Project Stabilization & Bug Fixing

This section documents the plan and steps taken to bring the application to a stable, runnable state by fixing critical startup and runtime errors.

### Plan & Steps Taken:

1.  **DONE - Fix `go_router` Refresh Stream:**
    - **Problem:** The application failed to start due to an incorrect call to the `authStateChanges` stream in `router.dart`.
    - **Solution:** Modified `router.dart` to correctly use `authService.authStateChanges` as a getter.

2.  **DONE - Fix `CheckoutProvider` Data Fetching Path:**
    - **Problem:** The checkout screen was throwing a `FirebaseException` because it was trying to fetch data from the wrong Firestore path (`/user/{uid}/address` instead of `/user/{uid}/addresses`).
    - **Solution:** Corrected the collection path in `firestore_service.dart` to `collection('addresses')`.

3.  **DONE - Display All Bank Accounts:**
    - **Problem:** The app was incorrectly filtering bank accounts and only showing ones with an `isActive: true` field.
    - **Solution:** Removed the filter from the `getBankAccounts` function in `firestore_service.dart`. The app now correctly fetches and displays **all** bank accounts.

4.  **DONE - Fix UI Duplication and Autofill Logic on Checkout Screen:**
    - **Problem 1 (UI):** The "Pilih Alamat Tersimpan" selector was appearing twice on the checkout screen.
    - **Solution 1:** Removed the redundant `AddressSelector` widget from within `delivery_info_widget.dart`.
    - **Problem 2 (Autofill):** The "Kode Pos" field was not being automatically filled when a saved address was selected.
    - **Solution 2:** Made the `Address.fromFirestore` method more robust by updating it to check for both `postalCode` (camelCase) and `postal_code` (snake_case) when parsing data from Firestore.

5.  **DONE - Fix Back Button Navigation on Checkout Screen:**
    - **Problem:** The back button on the checkout screen was throwing a "There is nothing to pop" error because the navigation used `context.go`, which replaces the navigation stack.
    - **Solution:** Changed the navigation call in `cart_screen.dart` from `context.go('/checkout')` to `context.push('/checkout')`. This preserves the navigation stack, allowing the back button (`context.pop()`) to function correctly.