# The Block

## How to Run

1. Open `TheBlock.xcodeproj` in Xcode.
2. Select the `TheBlock` scheme.
3. Run the app on an iOS 17+ simulator, such as iPhone 16 Pro.

The project does not require a backend or additional setup. Vehicle inventory is loaded from the bundled `vehicles.json` file.

## Time Spent

I spent around 6 hours working on this project. I started with building the core buyer flow first: inventory browsing, search/sort, vehicle details, and local bidding. After the main flow was working, I focused on polish, unit tests, fixing bugs I found, and documenting the product tradeoffs I made.

## Assumptions and Scope

- This is a native iOS interpretation of the original web/mobile challenge.
- The app is frontend-only and uses bundled JSON data.
- Bids are local app state only; there is no authentication, backend persistence, payment flow, or server-side validation.
- Buy Now is shown as a button to represent the product affordance, but the purchase workflow is intentionally out of scope.
- Auction timing is treated as display/eligibility logic for the prototype, not a full auction lifecycle system.

## Stack

- **Frontend:** SwiftUI
- **Architecture:** Simple MVVM-style view models
- **Backend:** None
- **Database:** None; bundled JSON plus in-memory bid state
- **Tests:** XCTest

## What I Built

I built a SwiftUI iOS app for browsing OPENLANE-style vehicle inventory. Buyers can search and sort vehicles, filter by useful criteria, open a detail screen with specs and condition information, view images, and place local bids.

The app keeps the implementation intentionally simple and reviewable. Most business logic lives in small view models, while SwiftUI views focus on presentation.

## Notable Decisions

- I preserved the provided `vehicles.json` data as-is. The placeholder image service returns SVGs when no format is specified, so the app normalizes those URLs to PNG at display time instead of editing the source data.
- I left VIN off the primary browsing card to keep the inventory scannable. Buyer-facing summary details appear in the list, while deeper identifiers can stay in the detail screen.
- I show auction start time and a non-functional Buy Now button, but left full auction lifecycle logic out of scope. In a production app, Buy Now would need confirmation, payment/deposit handling, inventory locking, bid cancellation/closure, and server-side validation.
- Auction end handling would need clear reserve logic. If the final bid is below reserve, the vehicle should not automatically sell, it should move into a reserve-not-met or seller follow-up state.

## Testing

I added XCTest coverage, which I verified in Xcode with an iPhone 16 Pro simulator, around the view-model behavior that drives the main buyer flow:

- Inventory loading and load failures
- Search, including multi-keyword searches across different vehicle fields
- Sorting and filtering behavior
- Bid state seeding and preserving local bids across reloads
- Valid and invalid bid attempts
- Blocking bids before an auction starts
- Clearing stale inline bid success/error messages

## What I'd Do With More Time

- Add a toggle to switch inventory between grid and list views.
- Add a comparison page for reviewing selected vehicles side by side.
- Group inventory into useful sections, such as ending soon, newer vehicles, classic cars, low mileage, by make, location, and vehicles with no bids yet.
- Show auction start time on inventory cards so buyers can understand whether a vehicle is open for bidding before navigating into detail.
- Consider showing upcoming auctions in the main inventory to build anticipation, with clear "starts soon" messaging or grouping so buyers can distinguish them from auctions that are already open.
- Add a real auction end state, including countdowns, reserve handling, and closed-auction UI.
- Add backend-backed bid validation so bid state is consistent across users/devices.
- Expand on testing, add more unit tests, regression tests, and test across multiple devices.
