# Guardian+ mobile app (Flutter)

Flutter version of the Guardian+ app: Care Circle members follow and respond to the alerts of the person under their care.

## Structure

Each bounded context lives in `lib/features/<context>/` with the same four layers as the Android app:

| Layer | Contents |
|---|---|
| `domain` | Entities, value objects and repository interfaces |
| `application` | One use case per class, with an `execute` method |
| `infrastructure` | `remote/` (API classes over `http` and DTOs with `fromJson`), `mappers/` (DTO → domain extensions) and `repositories/` (implementations) |
| `presentation` | One folder per screen: `*_page.dart`, `*_state.dart` (immutable, with `copyWith`), `*_view_model.dart` (`ChangeNotifier`) and `components/` |

Shared code is in `lib/core/`: the theme, the `ApiClient` every API uses, the care context of the signed-in account and
the `get_it` service locator (`core/service_locator.dart`).

## Running it

```bash
flutter pub get
flutter run
```

The app calls the deployed API by default. To use a backend running on this machine:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1/
```

(`10.0.2.2` is the host machine from the Android emulator; use `http://localhost:8080/api/v1/` on the iOS simulator.)

## Tests

```bash
flutter test
```
