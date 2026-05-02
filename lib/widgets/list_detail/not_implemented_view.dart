import 'package:flutter/material.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class NotImplementedItemsView extends StatelessWidget {
  const NotImplementedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyInfoCard(
      icon: Icons.construction_outlined,
      title: 'Unsupported list type',
      subtitle: 'This list type is not supported by the current app version.',
    );
  }
}
