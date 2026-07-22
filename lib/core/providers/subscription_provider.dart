import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../services/purchase_service.dart';

/// Whether the signed-in user currently holds an active "Uni-Verse Pro"
/// entitlement. Backed by RevenueCat's live CustomerInfo listener, so it
/// updates immediately after a purchase, renewal, or cancellation — no app
/// restart needed. Firestore's users/{uid}.isPro is kept in sync as a
/// best-effort mirror for the admin panel; RevenueCat stays the source of
/// truth for gating logic in this app.
final subscriptionProvider = StreamProvider<bool>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(false);

  final controller = StreamController<bool>();

  void onUpdate(CustomerInfo info) {
    final isPro = PurchaseService.isPro(info);
    if (!controller.isClosed) controller.add(isPro);
    _mirrorToFirestore(uid, isPro);
  }

  Purchases.addCustomerInfoUpdateListener(onUpdate);

  PurchaseService.configure(appUserId: uid).then((_) async {
    final info = await PurchaseService.getCustomerInfo();
    onUpdate(info);
  }).catchError((_) {
    // Offline or misconfigured — fall back to "not Pro" rather than hang.
    if (!controller.isClosed) controller.add(false);
  });

  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(onUpdate);
    controller.close();
  });

  return controller.stream;
});

Future<void> _mirrorToFirestore(String uid, bool isPro) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'isPro': isPro}, SetOptions(merge: true));
  } catch (_) {
    // Best-effort only — RevenueCat remains the source of truth for gating.
  }
}
