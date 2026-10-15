import 'package:nightout/models/app/dropdown.option.dart';

abstract final class Lang {
  static const th = DropdownOption(value: 'th', label: 'ไทย');
  static const en = DropdownOption(value: 'en', label: 'English');

  static const list = [th, en];
}
