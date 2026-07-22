import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/providers/subscription_provider.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../../core/theme/app_colors.dart';

const _proPerks = [
  ('Unlimited notes & drawings', Icons.draw_rounded),
  ('Ad-free, forever', Icons.block_rounded),
  ('Advanced study analytics', Icons.insights_rounded),
  ('Priority support', Icons.support_agent_rounded),
];

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  Offerings? _offerings;
  Package? _selected;
  bool _loadingOfferings = true;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await PurchaseService.getOfferings();
      final packages = offerings.current?.availablePackages ?? const [];
      setState(() {
        _offerings = offerings;
        _selected = packages.isNotEmpty ? packages.first : null;
        _loadingOfferings = false;
      });
    } catch (e) {
      setState(() {
        _error = "Couldn't load plans — check your connection and try again.";
        _loadingOfferings = false;
      });
    }
  }

  Future<void> _purchase() async {
    final package = _selected;
    if (package == null) return;
    setState(() {
      _purchasing = true;
      _error = null;
    });
    try {
      await PurchaseService.purchasePackage(package);
      if (mounted) Navigator.of(context).pop();
    } on PurchasesErrorCode catch (_) {
      setState(() => _error = 'Purchase failed — please try again.');
    } catch (e) {
      // RevenueCat throws a PlatformException wrapping PurchasesError; a
      // user-cancelled purchase shouldn't surface as an error message.
      final message = e.toString();
      if (!message.toLowerCase().contains('cancel')) {
        setState(() => _error = 'Purchase failed — please try again.');
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _purchasing = true;
      _error = null;
    });
    try {
      final info = await PurchaseService.restore();
      if (!mounted) return;
      if (PurchaseService.isPro(info)) {
        Navigator.of(context).pop();
      } else {
        setState(() => _error = 'No active purchases found for this account.');
      }
    } catch (e) {
      setState(() => _error = "Couldn't restore purchases — try again.");
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(subscriptionProvider).value ?? false;
    final packages = _offerings?.current?.availablePackages ?? const [];

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Uni-Verse Pro',
                  style: GoogleFonts.nunito(
                      fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                isPro
                    ? "You're all set — thanks for supporting Uni-Verse!"
                    : 'Everything you need to stay on top of your semester.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              if (isPro)
                _ProActiveCard()
              else ...[
                for (final perk in _proPerks) _PerkRow(text: perk.$1, icon: perk.$2),
                const SizedBox(height: 28),
                if (_loadingOfferings)
                  const Center(child: CircularProgressIndicator(color: AppColors.violet))
                else if (packages.isEmpty)
                  Text(
                    'No plans are available right now — please try again later.',
                    style: GoogleFonts.inter(color: AppColors.muted),
                  )
                else ...[
                  for (final package in packages)
                    _PlanTile(
                      package: package,
                      selected: _selected?.identifier == package.identifier,
                      onTap: () => setState(() => _selected = package),
                    ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: GoogleFonts.inter(color: AppColors.coral, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_purchasing || _selected == null) ? null : _purchase,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _purchasing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Continue',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _purchasing ? null : _restore,
                    child: Text('Restore Purchases',
                        style: GoogleFonts.inter(color: AppColors.muted, fontSize: 13)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final String text;
  final IconData icon;

  const _PerkRow({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFA08FFF), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Package package;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({required this.package, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.violet.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.violet : Colors.white24, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? const Color(0xFFA08FFF) : Colors.white38,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(product.title.isNotEmpty ? product.title : package.identifier,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
              ),
              Text(product.priceString,
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProActiveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.violet),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFA08FFF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Uni-Verse Pro is active on this account.',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
