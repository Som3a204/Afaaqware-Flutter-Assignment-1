# Mini Shop — Flutter E-Commerce Demo

A small app with mock login, a product grid, and a cart. It is intentionally narrow: the goal is a clear structure, predictable state, and decisions I can explain.

## Running it

```bash
flutter create .        # generates android/ios/web folders (lib/, pubspec.yaml are kept)
flutter pub get
flutter run
flutter test            # unit tests for the cart logic
```

Demo login: `test@example.com` / `password123`. Any other credentials show an error.

## 1. Approach

I built it in the order of the user flow, and kept the UI free of business logic at each step:

1. Models and mock repositories (data layer).
2. Controllers that own state (`ChangeNotifier`).
3. Screens that only render state and forward user actions.

Features: **login** (validated form, simulated network call, error message), **home** (product grid with loading / error / empty / refresh states and a live cart badge), **cart** (quantity +/−, remove with undo, running total, empty state).

## 2. Architecture and project structure

Feature-first folders, with a light data / presentation split inside each feature:

```
lib/
  main.dart, app.dart          # entry point, providers, auth gate
  core/money.dart              # shared helpers
  features/
    auth/      data/ (AuthRepository + mock)   presentation/ (AuthController, LoginScreen)
    products/  models/ data/ (ProductRepository + mock)   presentation/ (controller, HomeScreen, widgets)
    cart/      models/ presentation/ (CartController, CartScreen, widgets)
test/cart_controller_test.dart
```

**Why:** everything for a feature sits together, so it is easy to find, change, or delete. Repositories are abstract classes, so replacing a mock with a real API means writing one new class and changing one line in `app.dart`. I did not add a domain/use-case layer: with this little logic it would be ceremony without benefit.

## 3. State management: Provider + ChangeNotifier

- It is small, officially recommended for simple apps, and has almost no boilerplate, which fits the app's size.
- Three controllers, each with one responsibility: `AuthController`, `ProductController`, `CartController`.
- They are created once **above `MaterialApp`**. That is why the cart keeps its data when navigating Home ↔ Cart: the state does not belong to any screen.
- Rebuilds are kept narrow: the app-bar badge uses `Selector` so only it rebuilds when the quantity changes; widgets use `read` for actions and `watch`/`Consumer` only for rendering.

If the app grew (async caching, dependency graphs, many screens), I would move to Riverpod or Bloc for better testability and compile-time safety.

## 4. How the main states are handled

| Area | States | Handling |
|---|---|---|
| Auth | unauthenticated / loading / authenticated (+ error message) | `AuthGate` picks Login or Home from the status, so there is no manual navigation and no way to "go back" to login. Button is disabled and shows a spinner while loading; double submits are ignored. |
| Products | loading / loaded / error / empty | Spinner on first load, retry button on error, pull-to-refresh keeps the current grid visible instead of flashing a spinner. |
| Cart | empty / has items | Single `Map<productId, CartItem>`; totals are derived getters, never stored, so they cannot go out of sync. Empty state offers a way back to the products. |
| Images | loading / failed | Shared `ProductImage` widget shows a spinner or a placeholder icon. |

## 5. Important technical decisions

- **Money as integer cents.** Avoids floating-point errors in totals; converted to text only for display.
- **Cart keyed by product id.** Adding the same product increments quantity; a product can never appear twice.
- **Decrementing at quantity 1 removes the item**, so the cart never contains quantity 0. The explicit remove button also offers **Undo**.
- **Immutable models** (`Product`, `CartItem`) with `copyWith`; controllers expose unmodifiable lists.
- **Cart is cleared on logout**, since it belongs to the session.
- **Abstract repositories** for auth and products, so mocks are replaceable.
- **Minimal dependencies:** only `provider`.
- **Form validation** (email format, password length) before the "network" call; unit tests cover the cart logic, which is the part with real business rules.

## 6. Challenges

- **Where should the cart live?** Putting it in a screen would lose it on navigation; the fix was to scope it at the app root.
- **Avoiding needless rebuilds.** A naive `watch` in the Home screen would rebuild the entire grid on every cart change; I isolated the badge with `Selector`.
- **Edge cases around quantity** (what happens at 1, undo ordering) needed explicit decisions rather than defaults.
- **Image reliability.** Network images can be slow or fail, so loading and error states were needed to avoid a broken-looking UI.

## 7. What I would improve for production

- Real authentication (token auth, secure storage via `flutter_secure_storage`, refresh, session restore on launch).
- Real API with a typed client, pagination, retries, and proper error types instead of a generic error.
- Persist the cart (local DB or server-side cart) so it survives app restarts; handle price changes and stock.
- Navigation with `go_router` (deep links, route guards) instead of `Navigator.push`.
- Image caching (`cached_network_image`), search/filter, product detail page, and checkout flow.
- Localization and currency formatting with `intl`; accessibility audit (semantics, large text).
- Widget and integration tests for login and cart flows, plus CI (`flutter analyze`, tests).
- Error monitoring/analytics and environment-based configuration (flavors).
- Undo restores an item at the end of the list; keeping its original position would need an ordered list or index.
