import 'package:flutter/material.dart';
import 'package:flutter_bootcamp_deck/theme/palette.dart';
import 'package:flutter_bootcamp_deck/theme/tokens.dart';

/// How a row's trailing control behaves — the part the server chooses.
enum RowCta { radio, info, none }

/// The tone a description line carries. The point of §9 is that the *server*
/// picks this, not the client.
enum RowTone { normal, info, error }

/// One payment method row, described entirely by data. Nothing here is
/// hard-coded per-row in the widget layer — which is the whole BFF argument.
class PaymentRowData {
  const PaymentRowData({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tone = RowTone.normal,
    this.cta = RowCta.radio,
    this.enabled = true,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final RowTone tone;
  final RowCta cta;
  final bool enabled;
}

/// A neutral reconstruction of a "select payment method" screen — generic
/// rows, synthetic balances, no real product. It exists to be read as a
/// hierarchy on slide 44 and annotated against a contract on slides 45-47.
const paymentRows = [
  PaymentRowData(
    id: 'row-rewards',
    icon: Icons.stars_outlined,
    title: 'Rewards Points',
    subtitle: '1,250 pts available',
  ),
  PaymentRowData(
    id: 'row-wallet',
    icon: Icons.account_balance_wallet_outlined,
    title: 'Wallet',
    subtitle: 'Balance: 500.000',
  ),
  PaymentRowData(
    id: 'row-paylater',
    icon: Icons.schedule_outlined,
    title: 'Pay Later',
    subtitle: 'Due on the 1st',
  ),
  PaymentRowData(
    id: 'row-instalments',
    icon: Icons.calendar_month_outlined,
    title: 'Pay Later Instalments',
    subtitle: 'Limit 500.000',
    tone: RowTone.info,
    cta: RowCta.info,
  ),
  PaymentRowData(
    id: 'row-bank',
    icon: Icons.account_balance_outlined,
    title: 'Bank Account',
    subtitle: 'Under maintenance',
    tone: RowTone.error,
    cta: RowCta.none,
    enabled: false,
  ),
  PaymentRowData(
    id: 'row-card',
    icon: Icons.credit_card_outlined,
    title: 'Credit or debit card',
    subtitle: 'Add a new card',
    cta: RowCta.none,
  ),
];

const _regionIds = {
  'header',
  'section-title',
  'row-rewards',
  'row-wallet',
  'row-paylater',
  'row-instalments',
  'row-bank',
  'row-card',
  'cta',
};

/// The screen itself, with every annotatable region carrying a stable id so
/// a slide can outline exactly one of them.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({
    this.highlightedRegions = const {},
    this.width = 360,
    super.key,
  });

  final Set<String> highlightedRegions;
  final double width;

  /// Whether [id] names a region this screen can outline. Used by the tests
  /// so a typo in a slide becomes a failure rather than a silently missing
  /// highlight.
  static bool regionExists(String id) => _regionIds.contains(id);

  bool _lit(String id) => highlightedRegions.contains(id);

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: const EdgeInsets.all(Tokens.gapSm),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(Tokens.radius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Region(
              id: 'header',
              lit: _lit('header'),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, color: Palette.textPrimary, size: 20),
                  SizedBox(width: Tokens.gapXs),
                  Expanded(
                    child: Text(
                      'Select payment method',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tokens.gapSm),
            _Region(
              id: 'section-title',
              lit: _lit('section-title'),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment methods',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Swipe left to set as default',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Palette.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Tokens.gapXs),
            for (final row in paymentRows)
              _Region(
                id: row.id,
                lit: _lit(row.id),
                child: PaymentRow(data: row),
              ),
            const SizedBox(height: Tokens.gapSm),
            _Region(
              id: 'cta',
              lit: _lit('cta'),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Palette.blue,
                    borderRadius: BorderRadius.circular(Tokens.radius),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

/// One row. The three things the server controls — the description's tone,
/// the trailing control, and whether the row is enabled — are all read off
/// [PaymentRowData], never branched on the row's identity.
class PaymentRow extends StatelessWidget {
  const PaymentRow({required this.data, super.key});

  final PaymentRowData data;

  Color get _subtitleColor => switch (data.tone) {
        RowTone.normal => Palette.textSecondary,
        RowTone.info => Palette.amber,
        RowTone.error => Palette.red,
      };

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: data.enabled ? 1.0 : Tokens.dimmed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(data.icon, color: Palette.textPrimary, size: 20),
              const SizedBox(width: Tokens.gapXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _subtitleColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              switch (data.cta) {
                RowCta.radio => const Icon(
                    Icons.radio_button_unchecked,
                    color: Palette.textSecondary,
                    size: 18,
                  ),
                RowCta.info => const Icon(
                    Icons.info_outline,
                    color: Palette.amber,
                    size: 18,
                  ),
                RowCta.none => const Icon(
                    Icons.chevron_right,
                    color: Palette.textSecondary,
                    size: 18,
                  ),
              },
            ],
          ),
        ),
      );
}

/// Wraps a region so a slide can outline it without changing its layout.
class _Region extends StatelessWidget {
  const _Region({required this.id, required this.lit, required this.child});

  final String id;
  final bool lit;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        key: ValueKey('region-$id'),
        duration: Tokens.fade,
        curve: Tokens.curve,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: lit ? Palette.blue : Colors.transparent,
            width: Tokens.strokeWidth,
          ),
          borderRadius: BorderRadius.circular(Tokens.gapXs),
        ),
        child: child,
      );
}
