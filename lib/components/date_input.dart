import 'package:polymer/polymer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_browser.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbols.dart';
import 'dart:async';
import 'dart:html';

@CustomTag('date-input')
class XDateInput extends PolymerElement {
  @observable int firstDayOfWeek;
  @observable List<String> monthTexts;
  @observable List<String> weekdayTexts;
  DateTime today = new DateTime.now();
  @observable bool showDiv = false;
  Timer timer;
  @published String inputid = "";
  @published String inputplaceholder = "";
  @published int inputmaxlength = 9999;
  @published String value;
  @observable DateTime date = new DateTime.now();
  @observable List<List<int>> calendarList = toObservable([]);

  XDateInput.created() : super.created() {
    findSystemLocale().then((_) {
      initializeDateFormatting(Intl.systemLocale, null).then((_) {
        _initializeTexts(new DateFormat.E().dateSymbols);
      });
    });
    onPropertyChange(this, #date, () {
      _calculateCalendarList();
    });
    onPropertyChange(this, #firstDayOfWeek, () {
      _calculateCalendarList();
    });
  }

  _calculateCalendarList() {
    if (date == null || firstDayOfWeek == null) return;
    DateTime first = new DateTime(date.year, date.month, 1);
    DateTime last = new DateTime(date.year, date.month + 1, 1).subtract(new Duration(days: 1));
    calendarList.clear();
    List<int> weekList = toObservable([null, null, null, null, null, null, null]);
    int pos = first.weekday - firstDayOfWeek;
    if (pos >= 7) pos -= 7;
    if (pos < 0) pos += 7;
    for (int i = 1; i <= last.day; i++) {
      weekList[pos] = i;
      pos++;
      if (pos >= 7) {
        calendarList.add(weekList);
        weekList = toObservable([null, null, null, null, null, null, null]);
        pos = 0;
      }
    }
    if (pos > 0) calendarList.add(weekList);
  }

  bool isToday(int day) {
    if (date.year == today.year && date.month == today.month && day == today.day) return true; else return false;
  }
  void chooseDay(Event e, var detail, Element sender) {
    num day = int.parse(sender.attributes["data-day"]);
    date = new DateTime(date.year, date.month, day);
    value = date.toString().substring(0, 10);
    showDiv = false;
  }
  void onValueChange(Event e, var detail, Element sender) {
    try {
      date = DateTime.parse(value);
    } catch (e) {
      date = new DateTime.now();
    }
  }
  void show(Event e, var detail, Element sender) {
    onValueChange(e, detail, sender);
    showDiv = !showDiv;
  }
  void close(Event e, var detail, Element sender) {
    showDiv = false;
  }
  void previousYear(Event e, var detail, Element sender) {
    date = new DateTime(date.year - 1, date.month, 1);
    value = date.toString().substring(0, 10);
  }
  void nextYear(Event e, var detail, Element sender) {
    date = new DateTime(date.year + 1, date.month, 1);
    value = date.toString().substring(0, 10);
  }
  void previousMonth(Event e, var detail, Element sender) {
    date = new DateTime(date.year, date.month - 1, 1);
    value = date.toString().substring(0, 10);
  }
  void nextMonth(Event e, var detail, Element sender) {
    date = new DateTime(date.year, date.month + 1, 1);
    value = date.toString().substring(0, 10);
  }
  String get monthText {
    return monthTexts[date.month - 1];
  }
  void _initializeTexts(DateSymbols ds) {
    firstDayOfWeek = ds.FIRSTDAYOFWEEK;
    weekdayTexts = [];
    for (int i = 0; i < 7; i++) {
      int k = firstDayOfWeek + i;
      if (k >= 7) k = k - 7;
      weekdayTexts.add(ds.STANDALONESHORTWEEKDAYS[k]);
    }
    monthTexts = ds.STANDALONESHORTMONTHS;
  }
}
