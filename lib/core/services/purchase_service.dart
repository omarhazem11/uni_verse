import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat entitlement identifier configured in the RevenueCat dashboard.
/// Must match the entitlement attached to the "Uni-Verse Pro" product(s).
const kProEntitlementId = 'Uni-verse Pro';

/// Fill these in from the RevenueCat dashboard (Project Settings → API keys)
/// before shipping — purchases will fail without real keys.
// TODO: swap for the real Android/iOS store API keys before release — this
// Test Store key only talks to RevenueCat's mock backend, not Play/App Store.
const _revenueCatApiKeyAndroid = 'test_OEXqLdXmTPInIUpbIbnUPrsHfwz';
const _revenueCatApiKeyIOS = 'test_OEXqLdXmTPInIUpbIbnUPrsHfwz';

/// Thin wrapper around the RevenueCat SDK — handles configuration, identity
/// syncing with our own Firebase uid, and the purchase/restore calls used by
/// the paywall.
class PurchaseService {
  PurchaseService._();

  static bool _configured = false;
  static String? _currentAppUserId;

  /// Configures the SDK once per app process, then re-identifies via
  /// [Purchases.logIn] on every later call (e.g. logging into a different
  /// account after sign-out). RevenueCat's own guidance is to call
  /// `configure` exactly once and use `logIn`/`logOut` for identity
  /// switches — calling `configure` again is a no-op that leaves the SDK
  /// pinned to whatever anonymous ID `logOut()` last created, which is why
  /// isPro silently stuck at false after a logout/login cycle.
  static Future<void> configure({required String appUserId}) async {
    if (!_configured) {
      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? _revenueCatApiKeyIOS
          : _revenueCatApiKeyAndroid;
      await Purchases.setLogLevel(LogLevel.info);
      await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = appUserId,
      );
      _configured = true;
      _currentAppUserId = appUserId;
      return;
    }
    if (_currentAppUserId != appUserId) {
      await Purchases.logIn(appUserId);
      _currentAppUserId = appUserId;
    }
  }

  static Future<void> logOut() async {
    if (!_configured) return;
    await Purchases.logOut();
    _currentAppUserId = null;
  }

  static Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  static Future<Offerings> getOfferings() => Purchases.getOfferings();

  static Future<CustomerInfo> purchasePackage(Package package) =>
      Purchases.purchasePackage(package);

  static Future<CustomerInfo> restore() => Purchases.restorePurchases();

  static bool isPro(CustomerInfo info) =>
      info.entitlements.active.containsKey(kProEntitlementId);
}
