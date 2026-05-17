import 'package:flutter/material.dart';
import 'package:pesalistas/pages/catalog_item_picker_page.dart';

class GenericCatalogPage extends StatelessWidget {
  const GenericCatalogPage({super.key, this.groupId});

  final String? groupId;

  @override
  Widget build(BuildContext context) {
    return CatalogItemPickerPage(selectionMode: false, groupId: groupId);
  }
}
