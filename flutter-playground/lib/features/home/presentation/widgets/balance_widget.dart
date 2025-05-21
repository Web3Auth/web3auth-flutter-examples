import 'package:flutter/material.dart';
import 'package:flutter_playground/core/utils/strings.dart';

class BalanceWidget extends StatelessWidget {
  final String balance;
  final String ticker;
  final String chainId;

  const BalanceWidget({
    super.key,
    required this.balance,
    required this.ticker,
    required this.chainId,
  });

  @override
  Widget build(BuildContext context) {
    final labelLargeTheme = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 16,
        );

    final headlineSmallTheme = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(StringConstants.walletBalanceText, style: labelLargeTheme),
            Text(StringConstants.chainIdText, style: labelLargeTheme),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$balance $ticker", style: headlineSmallTheme),
            Text(chainId, style: headlineSmallTheme),
          ],
        )
      ],
    );
  }
}
