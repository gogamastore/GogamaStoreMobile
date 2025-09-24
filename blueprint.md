
# Application Blueprint

## Overview

This document outlines the core structure, design principles, and technical architecture of the Gogama Store application. It serves as a single source of truth for development, ensuring consistency and clarity across all features.

## Firestore Data Structure

This section details the schema for the Firestore collections used in the application.

### `orders` Collection

This collection stores all customer order information.

**Document ID:** `orderId` (auto-generated)

| Field                  | Type        | Description                                                                                             | Example                                                                                                                              |
| ---------------------- | ----------- | ------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `created_at`           | `string`    | ISO 8601 timestamp indicating when the order was created.                                               | `"2025-09-20T11:11:32.354Z"`                                                                                                         |
| `customer`             | `string`    | The name of the customer who placed the order.                                                          | `"Rhey"`                                                                                                                             |
| `customerDetails`      | `map`       | An object containing detailed information about the customer.                                           | `{ "address": "...", "name": "...", "whatsapp": "..." }`                                                                             |
| `  ‣ address`          | `string`    | The full shipping address of the customer.                                                              | `"Jl Borong Raya Nomor 100, Makassar, 90234"`                                                                                        |
| `  ‣ name`             | `string`    | The full name of the customer, for shipping purposes.                                                   | `"Rhey"`                                                                                                                             |
| `  ‣ whatsapp`         | `string`    | The customer's WhatsApp number, including country code.                                                | `"62895635299075"`                                                                                                                   |
| `customerId`           | `string`    | The unique user ID (UID) from Firebase Authentication corresponding to the customer.                    | `"8ShveN2c3gbndLn4d95J3Hs4Hjo2"`                                                                                                      |
| `date`                 | `timestamp` | Firestore timestamp object representing the exact date and time the order was placed.                   | `September 20, 2025 at 7:11:32 PM UTC+8`                                                                                             |
| `paymentMethod`        | `string`    | The payment method chosen by the customer.                                                              | `"bank_transfer"`                                                                                                                    |
| `paymentProofFileName` | `string`    | The filename of the uploaded payment proof, if any.                                                     | `""`                                                                                                                                 |
| `paymentProofId`       | `string`    | A unique ID associated with the payment proof upload.                                                   | `""`                                                                                                                                 |
| `paymentProofUploaded` | `boolean`   | A flag indicating whether a payment proof has been uploaded.                                            | `false`                                                                                                                              |
| `paymentProofUrl`      | `string`    | The public URL to the payment proof image stored in Firebase Storage.                                   | `"https://firebasestorage.googleapis.com/.../payment_proof.jpg"`                                                                     |
| `paymentStatus`        | `string`    | The current status of the payment. Can be `Paid`, `paid`, `Unpaid`, or `unpaid`.                        | `"Paid"`                                                                                                                             |
| `productIds`           | `array`     | An array of strings, where each string is the `productId` of an item in the order.                      | `["AC3Humo7XxFxQFQkYsK2"]`                                                                                                            |
| `products`             | `array`     | An array of maps, where each map represents a product line item in the order.                           | `[{ "image": "...", "name": "...", "price": ..., "productId": "...", "quantity": ... }]`                                              |
| `  ‣ image`            | `string`    | URL to the product image.                                                                               | `"https://firebasestorage.googleapis.com/.../product_image.webp"`                                                                    |
| `  ‣ name`             | `string`    | The name of the product.                                                                                | `"Azarine Barrier Moisturizer 30gr"`                                                                                                 |
| `  ‣ price`            | `number`    | The price of a single unit of the product at the time of purchase.                                      | `43000`                                                                                                                              |
| `  ‣ productId`        | `string`    | The unique ID of the product.                                                                           | `"AC3Humo7XxFxQFQkYsK2"`                                                                                                             |
| `  ‣ quantity`         | `number`    | The number of units of this product purchased in the order.                                             | `3`                                                                                                                                  |
| `shippingFee`          | `number`    | The cost of shipping for the order.                                                                     | `15000`                                                                                                                              |
| `shippingMethod`       | `string`    | The shipping method selected for the order.                                                             | `"Pengiriman oleh Kurir"`                                                                                                            |
| `status`               | `string`    | The overall status of the order. Handles various casings (`processing`, `Delivered`, etc.).             | `"processing"`                                                                                                                       |
| `stockUpdateTimestamp` | `string`    | ISO 8601 timestamp indicating when the stock was last updated for this order.                           | `"2025-09-20T11:11:32.348Z"`                                                                                                         |
| `stockUpdated`         | `boolean`   | A flag to confirm if the stock level has been adjusted after the order was placed.                      | `true`                                                                                                                               |
| `subtotal`             | `number`    | The total cost of all products before shipping fees.                                                    | `129000`                                                                                                                             |
| `total`                | `number`    | The final total amount for the order (subtotal + shipping).                                             | `144000`                                                                                                                             |
| `updatedAt`            | `timestamp` | Firestore timestamp indicating the last time the order document was modified.                           | `September 20, 2025 at 10:24:21 PM UTC+8`                                                                                            |
| `updated_at`           | `string`    | ISO 8601 timestamp for the last update.                                                                 | `"2025-09-20T11:11:32.354Z"`                                                                                                         |

