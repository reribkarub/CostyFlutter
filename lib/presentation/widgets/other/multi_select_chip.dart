import 'package:costy/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../app_localizations.dart';
import '../../../keys.dart';

class MultiSelectChip<T> extends StatelessWidget {
  final Iterable<T> userList;
  final Iterable<T> selectedUserList;
  final Function(Iterable<T>) onSelectionChanged;
  final Function(T item) extractLabelFunction;

  const MultiSelectChip({
    Key key,
    this.userList,
    this.selectedUserList,
    this.onSelectionChanged,
    this.extractLabelFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Wrap(
          children: _buildChoiceList(context),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              key: const Key(Keys.multiSelectChipSelectAll),
              onPressed: () => onSelectionChanged(userList),
              child: Text(AppLocalizations.of(context).translate(
                  'expense_form_multi_select_chip_select_all_button')),
            ),
            FlatButton(
              key: const Key(Keys.multiSelectChipSelectNone),
              onPressed: () => onSelectionChanged([]),
              child: Text(AppLocalizations.of(context).translate(
                  'expense_form_multi_select_chip_select_none_button')),
            )
          ],
        ),
      ],
    );
  }

  List<Widget> _buildChoiceList(BuildContext ctx) {
    final List<Widget> choices = [];

    for (final item in userList) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          backgroundColor: Colors.grey,
          selectedColor: StyleConstants.primaryColor.withOpacity(0.8),
          key: Key("receiver_${extractLabelFunction(item)}"),
          label: Text(
            extractLabelFunction(item) as String,
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
            style: const TextStyle(color: Colors.white),
          ),
          selected: selectedUserList.contains(item),
          onSelected: (selected) {
            List.from(selectedUserList).add(item);
            selectedUserList.contains(item)
                ? onSelectionChanged(List.from(selectedUserList)..remove(item))
                : onSelectionChanged(List.from(selectedUserList)..add(item));
          },
        ),
      ));
    }

    return choices;
  }
}
