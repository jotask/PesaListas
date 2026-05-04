import 'package:flutter/material.dart';
import 'package:pesalistas/l10n/app_strings.dart';
import 'package:pesalistas/widgets/common/empty_info_card.dart';

class NotImplementedItemsView extends StatelessWidget {
  const NotImplementedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyInfoCard(
      icon: Icons.construction_outlined,
      title: S.unsupportedListType,
      subtitle: S.thisListTypeIsNotSupportedByTheCurrentAppVersion,
    );
  }
}
