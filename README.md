# Mini Shop — Flutter E-Commerce Demo

A small app with mock login, a product grid, and a cart. It is intentionally narrow: the goal is a clear structure, predictable state, and decisions I can explain.

## Running it

```bash
flutter create .        # generates android/ios/web folders (lib/, pubspec.yaml are kept)
flutter pub get
flutter run
flutter test            # unit tests for the cubits
```

Demo login: `test@example.com` / `password123`. Any other credentials show an error.

## 1. Approach

I built it in the order of the user flow, and kept the UI free of business logic at each step:

1. Models and mock repositories (data layer).
2. Cubits and immutable state classes that own all state.
3. Screens that only render state and forward user actions.

Features: **login** (validated form, simulated network call, error message), **home** (product grid with loading / error / empty / refresh states and a live cart badge), **cart** (quantity +/−, remove with undo, running total, empty state).

## 2. Architecture and project structure

Feature-first folders, with a light data / presentation split inside each feature:

```
lib/
  main.dart, app.dart          # entry point, BlocProviders, auth gate
  core/money.dart              # shared helpers
  features/
    auth/      data/ (AuthRepository + mock)   presentation/ (AuthCubit, AuthState, LoginScreen)
    products/  models/ data/ (ProductRepository + mock)   presentation/ (ProductCubit, ProductState, HomeScreen, widgets)
    cart/      models/ presentation/ (CartCubit, CartState, CartScreen, widgets)
test/          cart_cubit_test.dart, auth_cubit_test.dart
```

**Why:** everything for a feature sits together, so it is easy to find, change, or delete. Repositories are abstract classes, so replacing a mock with a real API means writing one new class and changing one line in `app.dart`. I did not add a domain/use-case layer: with this little logic it would be ceremony without benefit.

## 3. State management: Cubit (flutter_bloc)

- A **Cubit** is a small state holder: public methods call `emit(newState)`, and the UI listens to a stream of states. It gives the predictability of Bloc without defining event classes, which suits an app this size.
- Each feature has one Cubit and one **immutable state class**: `AuthCubit/AuthState`, `ProductCubit/ProductState`, `CartCubit/CartState`.
- State classes extend `Equatable`. A Cubit does not emit a state equal to the current one, and `BlocBuilder` / `BlocSelector` use equality to decide whether to rebuild. Models (`Product`, `CartItem`) are `Equatable` too, so equality works through nested data.
- Cubits are created once **above `MaterialApp`** with `MultiBlocProvider`. That is why the cart keeps its data when navigating Home ↔ Cart: the state does not belong to any screen.
- Rebuilds are kept narrow: the app-bar badge uses `BlocSelector` so only it rebuilds when the quantity changes; `context.read` is used for actions, `BlocBuilder` only for rendering.

If the app grew (multi-step flows, event tracing, debouncing), I would promote the relevant Cubit to a full Bloc to get explicit events.

## 4. How the main states are handled

| Area | States | Handling |
|---|---|---|
| Auth | unauthenticated / loading / authenticated (+ error message) | `AuthGate` picks Login or Home from `AuthState`, so there is no manual navigation and no way to "go back" to login. Button is disabled and shows a spinner while loading; double submits are ignored. |
| Products | loading / loaded / error / empty | Spinner on first load, retry button on error, pull-to-refresh keeps the current grid visible instead of flashing a spinner. |
| Cart | empty / has items | `CartState` holds one list of `CartItem`; totals are derived getters, never stored, so they cannot go out of sync. Empty state offers a way back to the products. |
| Images | loading / failed | Shared `ProductImage` widget shows a spinner or a placeholder icon. |

## 5. Important technical decisions

- **Immutable state, new object on every change.** Cubit methods build a new list and emit a new state; mutating a list in place would not be detected as a change and the UI would not rebuild.
- **Money as integer cents.** Avoids floating-point errors in totals; converted to text only for display.
- **Adding the same product increments quantity**; a product can never appear twice in the cart.
- **Decrementing at quantity 1 removes the item**, so the cart never contains quantity 0. The explicit remove button also offers **Undo**.
- **Cart is cleared on logout**, since it belongs to the session.
- **Abstract repositories** for auth and products, so mocks are replaceable and Cubits are testable with fakes.
- **Small dependency set:** `flutter_bloc` and `equatable`.
- **Tests target the logic:** cart rules and the auth state sequence (loading → authenticated / error), by asserting on `cubit.state` and `cubit.stream`.

## 6. Challenges

- **Where should the cart live?** Putting it in a screen would lose it on navigation; the fix was to provide it at the app root.
- **Equality and rebuilds.** With Cubit, state changes are detected by equality, so state classes and models needed proper value equality, and lists had to be copied rather than mutated.
- **Avoiding needless rebuilds.** A `BlocBuilder` around the whole Home screen would rebuild the grid on every cart change; I isolated the badge with `BlocSelector`.
- **Edge cases around quantity** (what happens at 1, undo ordering) needed explicit decisions rather than defaults.
- **Image reliability.** Network images can be slow or fail, so loading and error states were needed.

## 7. What I would improve for production

- Real authentication (token auth, secure storage via `flutter_secure_storage`, refresh, session restore on launch).
- Real API with a typed client, pagination, retries, and typed errors instead of a generic error state.
- Persist the cart (local DB or server-side cart) so it survives app restarts; handle price changes and stock.
- Clear the cart by reacting to auth changes (a `BlocListener`) instead of calling it from the logout button, so the UI does not have to coordinate two Cubits.
- Navigation with `go_router` (deep links, route guards) instead of `Navigator.push`.
- Image caching (`cached_network_image`), search/filter, product detail page, and checkout flow.
- Localization and currency formatting with `intl`; accessibility audit (semantics, large text).
- Widget tests with `bloc_test`/`mocktail` for the login and cart flows, plus CI (`flutter analyze`, tests).
- Undo restores an item at the end of the list; keeping its original position would need storing the index.
