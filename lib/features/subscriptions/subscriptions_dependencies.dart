import 'package:get_it/get_it.dart';
import 'package:guardian_plus_app/core/network/api_client.dart';
import 'package:guardian_plus_app/features/subscriptions/domain/subscription_repository.dart';
import 'package:guardian_plus_app/features/subscriptions/infrastructure/remote/subscriptions_api.dart';
import 'package:guardian_plus_app/features/subscriptions/infrastructure/repositories/subscription_repository_impl.dart';

void setupSubscriptions(GetIt getIt) {
  getIt.registerLazySingleton<SubscriptionsApi>(
    () => SubscriptionsApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(api: getIt<SubscriptionsApi>()),
  );
}
