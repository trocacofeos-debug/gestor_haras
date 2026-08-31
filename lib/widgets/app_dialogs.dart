import 'package:flutter/material.dart';
import 'popup_workspace.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String title = 'Popup',
  bool barrierDismissible = true,
}) {
  final workspace = PopupWorkspace.of(context);
  if (workspace == null) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }
  return workspace.show<T>(
    sourceContext: context,
    builder: builder,
    title: title,
    barrierDismissible: barrierDismissible,
  );
}

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) => showAppDialog<DateTime>(
  context: context,
  title: 'Selecionar data',
  builder: (_) => DatePickerDialog(
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  ),
);

Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  String? helpText,
  String? saveText,
  String? cancelText,
  String? confirmText,
  String? fieldStartLabelText,
  String? fieldEndLabelText,
}) => showAppDialog<DateTimeRange>(
  context: context,
  title: helpText ?? 'Selecionar período',
  builder: (_) => DateRangePickerDialog(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDateRange: initialDateRange,
    helpText: helpText,
    saveText: saveText,
    cancelText: cancelText,
    confirmText: confirmText,
    fieldStartLabelText: fieldStartLabelText,
    fieldEndLabelText: fieldEndLabelText,
  ),
);
