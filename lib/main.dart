import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'たこせん屋台',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE85D04)),
      scaffoldBackgroundColor: const Color(0xFFFFF8F0),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFFFF8F0),
        foregroundColor: Color(0xFF3B2416),
      ),
    ),
    home: const TakosenApp(),
  ),
);

class TakosenApp extends StatefulWidget {
  const TakosenApp({super.key});

  @override
  State<TakosenApp> createState() => _TakosenAppState();
}

class _TakosenAppState extends State<TakosenApp> {
  final foods = {'🐙 たこせん': 500, '🥚 卵煎餅': 400};
  final paidToppings = {'🐙 たこ焼き追加': 50, '🥚 卵トッピング': 50};
  late String food = foods.keys.first;
  String deco = 'なし';
  final selectedToppings = <String>{};
  int decoCount = 1, order = 0;
  bool agedama = false, aonori = false;
  String receipt = '';

  Widget choices(
    Iterable<String> items,
    String value,
    void Function(String) change,
  ) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final item in items)
        ChoiceChip(
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Text(item),
          ),
          selected: value == item,
          onSelected: (_) => setState(() => change(item)),
        ),
    ],
  );

  Widget sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtotal =
        foods[food]! +
        selectedToppings.length * 50 +
        (deco == 'なし' ? 0 : decoCount * 50);
    final tax = subtotal * 10 ~/ 110;
    final total = subtotal;

    final productImage = Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/takosen.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.25),
                  cacheWidth: 1200,
                  errorBuilder: (_, _, _) => ColoredBox(
                    color: colors.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 52),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '税込価格',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    food,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${foods[food]}円',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final products = choices(
      foods.keys.map((item) => '$item  ${foods[item]}円（税込）'),
      '$food  ${foods[food]}円（税込）',
      (item) => food = item.substring(0, item.lastIndexOf('  ')),
    );

    final toppings = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in paidToppings.keys)
          FilterChip(
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Text('$item  +${paidToppings[item]}円'),
            ),
            selected: selectedToppings.contains(item),
            onSelected: (selected) => setState(() {
              if (selected) {
                selectedToppings.add(item);
              } else {
                selectedToppings.remove(item);
              }
            }),
          ),
      ],
    );

    final decorations = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        choices(['なし', '❤️', '⭐', '🌸'], deco, (item) => deco = item),
        if (deco != 'なし') ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('デコ数'),
                IconButton(
                  tooltip: '減らす',
                  onPressed: decoCount > 0
                      ? () => setState(() => decoCount--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$decoCount',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: '増やす',
                  onPressed: decoCount < 3
                      ? () => setState(() => decoCount++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    Widget supply(String label, bool value, void Function(bool) change) =>
        CheckboxListTile(
          value: value,
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(label),
          onChanged: (selected) => setState(() => change(selected ?? false)),
        );

    final supplies = Column(
      children: [
        supply('🟡 揚げ玉', agedama, (value) => agedama = value),
        supply('🌿 青のり', aonori, (value) => aonori = value),
      ],
    );

    final bill = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 34,
            color: colors.onPrimaryContainer,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'お支払い金額（税込）',
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
                Text(
                  '$total円',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '内消費税 $tax円',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final submit = SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        icon: const Icon(Icons.shopping_cart_checkout),
        label: const Text('この内容で注文する'),
        onPressed: () => setState(() {
          order = Random().nextInt(999) + 1;
          receipt =
              '$food  ${foods[food]}円\n'
              '追加トッピング: ${selectedToppings.isEmpty ? 'なし' : selectedToppings.join('、')}\n'
              'デコレーション: ${deco == 'なし' ? 'なし' : '$deco × $decoCount'}\n'
              '🟡 揚げ玉: ${agedama ? 'あり' : 'なし'}\n'
              '🌿 青のり: ${aonori ? 'あり' : 'なし'}\n'
              '合計（税込）: $total円\n'
              '内消費税（10%）: $tax円';
        }),
      ),
    );

    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            margin: const EdgeInsets.only(top: 14),
            color: colors.secondaryContainer,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colors.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ご注文を承りました',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '注文番号 #$order',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(receipt, style: const TextStyle(height: 1.6)),
                ],
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('🐙 たこせん屋台')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
              children: [
                Text(
                  'お好みの一枚を作ろう',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B2416),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '商品とトッピングを選んでください',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                productImage,
                sectionCard(
                  context,
                  icon: Icons.restaurant_menu,
                  title: '商品を選ぶ',
                  subtitle: '価格はすべて税込です',
                  child: products,
                ),
                sectionCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: '追加トッピング',
                  subtitle: '1個50円（税込）',
                  child: toppings,
                ),
                sectionCard(
                  context,
                  icon: Icons.auto_awesome,
                  title: 'デコレーション',
                  subtitle: '1個50円（税込）・最大3個',
                  child: decorations,
                ),
                sectionCard(
                  context,
                  icon: Icons.volunteer_activism_outlined,
                  title: '無料サービス',
                  subtitle: 'お好みで選べます',
                  child: supplies,
                ),
                bill,
                submit,
                ticket,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
