import 'package:flutter/material.dart';

class NotImplementedItemsView extends StatelessWidget {
  const NotImplementedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            title: Text(
              'NOT IMPLEMENTED',
              style: TextStyle(decoration: TextDecoration.lineThrough),
            ),
            subtitle: Text('This Item is not implemented'),
          ),
        ),
      ],
    );
  }
}
