import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class NotImplementedItemsView extends StatelessWidget {
  const NotImplementedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyInfoCard(
      icon: Icons.construction_outlined,
      title: context.l10n.unsupportedListType,
      subtitle: context.l10n.thisListTypeIsNotSupportedByTheCurrentAppVersion,
    );
  }
}
