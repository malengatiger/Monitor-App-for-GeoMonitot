import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'data/project_position.dart';
import 'location/loc_bloc.dart';

List<String> logs = [];
bool isBusy = false;
List<Color> _colors = [];
Random _rand = Random(DateTime.now().millisecondsSinceEpoch);
Color getRandomColor() {
  _colors.clear();
  _colors.add(Colors.blue);
  _colors.add(Colors.pink);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.amber);
  _colors.add(Colors.indigo);
  _colors.add(Colors.lightBlue);
  _colors.add(Colors.lime);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.deepOrange);
  _colors.add(Colors.cyan);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.blue);
  _colors.add(Colors.pink);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);
  _colors.add(Colors.amber);
  _colors.add(Colors.indigo);
  _colors.add(Colors.lightBlue);
  _colors.add(Colors.lime);
  _colors.add(Colors.deepPurple);
  _colors.add(Colors.deepOrange);
  _colors.add(Colors.cyan);
  _colors.add(Colors.teal);
  _colors.add(Colors.red);
  _colors.add(Colors.green);

  _rand = Random(DateTime.now().millisecondsSinceEpoch * _rand.nextInt(10000));
  int index = _rand.nextInt(_colors.length - 1);
  sleep(const Duration(milliseconds: 2));
  return _colors.elementAt(index);
}

Color getRandomPastelColor() {
  _colors.clear();
  _colors.add(Colors.blue.shade50);
  _colors.add(Colors.grey.shade50);
  _colors.add(Colors.pink.shade50);
  _colors.add(Colors.teal.shade50);
  _colors.add(Colors.red.shade50);
  _colors.add(Colors.green.shade50);
  _colors.add(Colors.amber.shade50);
  _colors.add(Colors.indigo.shade50);
  _colors.add(Colors.lightBlue.shade50);
  _colors.add(Colors.lime.shade50);
  _colors.add(Colors.deepPurple.shade50);
  _colors.add(Colors.deepOrange.shade50);
  _colors.add(Colors.brown.shade50);
  _colors.add(Colors.cyan.shade50);

  _rand =
      Random(DateTime.now().millisecondsSinceEpoch * _rand.nextInt(10000));
  int index = _rand.nextInt(_colors.length - 1);
  return _colors.elementAt(index);
}

Future<bool>  isLocationValid({required ProjectPosition projectPosition, required double validDistance}) async {
  var distance = await locationBloc.getDistanceFromCurrentPosition(
      latitude: projectPosition.position!.coordinates[1],
      longitude: projectPosition.position!.coordinates[0]);

  if (distance <= validDistance) {
    return true;
  }
  return false;
}

class Styles {
  static const reallyTiny = 10.0;
  static const tiny = 12.0;
  static const small = 14.0;
  static const medium = 20.0;
  static const large = 32.0;
  static const reallyLarge = 52.0;

  static TextStyle greyLabelTiny = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: tiny,
    color: Colors.grey,
  );
  static TextStyle greyLabelSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.grey,
  );

  static TextStyle greyLabelMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.grey,
  );
  static TextStyle greyLabelLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.grey,
  );
  static TextStyle yellowBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.yellow,
  );
  static TextStyle yellowBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.yellow,
  );
  static TextStyle yellowMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.yellow,
  );
  static TextStyle yellowBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.yellow,
  );
  static TextStyle yellowBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.yellow,
  );
  static TextStyle yellowLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.yellow,
  );
  static TextStyle yellowReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.yellow,
  );
  /////
  static TextStyle blackBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.black,
  );
  static TextStyle blackSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.black,
  );
  static TextStyle blackTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.black,
  );
  static TextStyle blackReallyTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyTiny,
    color: Colors.black,
  );
  static TextStyle blackBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.black,
  );
  static TextStyle blackMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.black,
  );
  static TextStyle blackBoldLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: large,
    color: Colors.black,
  );
  static TextStyle blackBoldDash = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 48,
    color: Colors.black,
  );
  static TextStyle blackBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.black,
  );
  static TextStyle blackLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.black,
  );
  static TextStyle blackReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.black,
  );

  ////////
  static TextStyle pinkBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.pink,
  );
  static TextStyle pinkTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.pink,
  );
  static TextStyle pinkBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.pink,
  );
  static TextStyle pinkMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.pink,
  );
  static TextStyle pinkBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.pink,
  );
  static TextStyle pinkBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.pink,
  );
  static TextStyle pinkLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.pink,
  );
  static TextStyle pinkReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.pink,
  );
  /////////
  static TextStyle purpleBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.purple,
  );
  static TextStyle purpleTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.purple,
  );
  static TextStyle purpleBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.purple,
  );
  static TextStyle purpleMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.purple,
  );
  static TextStyle purpleSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.purple,
  );
  static TextStyle purpleBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.purple,
  );
  static TextStyle purpleBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.purple,
  );
  static TextStyle purpleLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.purple,
  );
  static TextStyle purpleReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.purple,
  );
  ///////
  static TextStyle blueBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.blue,
  );
  static TextStyle blueSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.blue,
  );
  static TextStyle blueTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.blue,
  );
  static TextStyle blueBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.blue,
  );
  static TextStyle blueMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.blue,
  );
  static TextStyle blueBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.blue,
  );
  static TextStyle blueBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.blue,
  );
  static TextStyle blueLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.blue,
  );
  static TextStyle blueReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.blue,
  );
  ////
  static TextStyle brownBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.brown,
  );
  static TextStyle brownBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.brown,
  );
  static TextStyle brownMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.brown,
  );
  static TextStyle brownBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.brown,
  );
  static TextStyle brownBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.brown,
  );
  static TextStyle brownLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.brown,
  );
  static TextStyle brownReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.brown,
  );
  ///////
  static TextStyle whiteBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.white,
  );
  static TextStyle whiteBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.white,
  );
  static TextStyle whiteMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.white,
  );
  static TextStyle whiteSmall = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: small,
    color: Colors.white,
  );
  static TextStyle whiteTiny = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: tiny,
    color: Colors.white,
  );
  static TextStyle whiteBoldLarge = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: large,
    color: Colors.white,
  );
  static TextStyle whiteBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.white,
  );
  static TextStyle whiteLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.white,
  );
  static TextStyle whiteReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.white,
  );
  /////
  static TextStyle tealBoldSmall = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: small,
    color: Colors.teal,
  );
  static TextStyle tealBoldMedium = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: medium,
    color: Colors.teal,
  );
  static TextStyle tealMedium = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: medium,
    color: Colors.teal,
  );
  static TextStyle tealBoldLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: large,
    color: Colors.teal,
  );
  static TextStyle tealBoldReallyLarge = const TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: reallyLarge,
    color: Colors.teal,
  );
  static TextStyle tealLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: large,
    color: Colors.teal,
  );
  static TextStyle tealReallyLarge = const TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: reallyLarge,
    color: Colors.teal,
  );

  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color yellow = Colors.yellow;
  static Color lightGreen = Colors.lightGreen;
  static Color lightBlue = Colors.lightBlue;
  static Color brown = Colors.brown;
  static Color pink = Colors.pink;
  static Color teal = Colors.teal;
  static Color purple = Colors.purple;
  static Color blue = Colors.blue;
}

prettyPrint(Map map, String name) {
  pp('$name \t{\n');
  if (map != null) {
    map.forEach((key, val) {
      pp('\t$key : $val ,\n');
    });
    pp('}\n\n');
  } else {
    pp('📍📍📍📍 prettyPrint: 📍📍📍📍📍📍📍📍 map is NULL - tag: $name 📍📍📍📍📍📍📍📍');
  }
}

pp(dynamic msg) {
  var time = getFormattedDateHourMinSec(DateTime.now().toString());
  if (msg is String) {
    debugPrint('$time ==> $msg');
  } else {
    pp('$time ==> $msg');
  }
}

String getFormattedDateLongWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('EEEE, dd MMMM yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShortWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd MMMM yyyy HH:mm:ss', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateLong(String date, BuildContext context) {
//  pp('\getFormattedDateLong $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('EEEE, dd MMMM yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      pp('++++++++++++++ Formatted date with locale == ${format.format(mDate.toLocal())}');
      return format.format(mDate.toLocal());
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShort(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd MMMM yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      pp('++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShortest(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd-MM-yyyy', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      pp('++++++++++++++ Formatted date with locale == ${format.format(mDate)}');
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

String getFormattedDateShortestWithTime(String date, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);

  initializeDateFormatting();
  var format = DateFormat('dd-MM-yyyy HH:mm', myLocale.toString());
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return format.format(mDate);
    } else {
      var mDate = DateTime.parse(date);
      return format.format(mDate.toLocal());
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

int getIntDate(String date, BuildContext context) {
  pp('\n---------------> getIntDate $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  assert(context != null);
  initializeDateFormatting();
  try {
    if (date.contains('GMT')) {
      var mDate = getLocalDateFromGMT(date, context);
      return mDate.millisecondsSinceEpoch;
    } else {
      var mDate = DateTime.parse(date);
      return mDate.millisecondsSinceEpoch;
    }
  } catch (e) {
    pp(e);
    return 0;
  }
}

String getFormattedDateHourMinute({required DateTime date, required BuildContext context}) {
  initializeDateFormatting();

  try {
    if (context == null) {
      var dateFormat = DateFormat('HH:mm');
      return dateFormat.format(date);
    } else {
      Locale myLocale = Localizations.localeOf(context);
      var dateFormat = DateFormat('HH:mm', myLocale.toString());
      return dateFormat.format(date);
    }
  } catch (e) {
    pp(e);
    return 'NoDate';
  }
}

DateTime getLocalDateFromGMT(String date, BuildContext context) {
  //pp('getLocalDateFromGMT string: $date'); //Sun, 28 Oct 2018 23:59:49 GMT
  Locale myLocale = Localizations.localeOf(context);

  //pp('+++++++++++++++ locale: ${myLocale.toString()}');
  initializeDateFormatting();
  try {
    var mDate = translateGMTString(date);
    return mDate.toLocal();
  } catch (e) {
    pp(e);
    throw e;
  }
}

DateTime translateGMTString(String date) {
  var strings = date.split(' ');
  var day = int.parse(strings[1]);
  var mth = strings[2];
  var year = int.parse(strings[3]);
  var time = strings[4].split(':');
  var hour = int.parse(time[0]);
  var min = int.parse(time[1]);
  var sec = int.parse(time[2]);
  var cc = DateTime.utc(year, getMonth(mth), day, hour, min, sec);

  //pp('##### translated date: ${cc.toIso8601String()}');
  //pp('##### translated local: ${cc.toLocal().toIso8601String()}');

  return cc;
}

int getMonth(String mth) {
  switch (mth) {
    case 'Jan':
      return 1;
    case 'Feb':
      return 2;
    case 'Mar':
      return 3;
    case 'Apr':
      return 4;
    case 'Jun':
      return 6;
    case 'Jul':
      return 7;
    case 'Aug':
      return 8;
    case 'Sep':
      return 9;
    case 'Oct':
      return 10;
    case 'Nov':
      return 11;
    case 'Dec':
      return 12;
  }
  return 0;
}

String getUTCDate() {
  initializeDateFormatting();
  String now = DateTime.now().toUtc().toIso8601String();
  return now;
}

String getUTC(DateTime date) {
  initializeDateFormatting();
  String now = date.toUtc().toIso8601String();
  return now;
}

String getFormattedDate(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.yMMMd();
    return format.format(d);
  } catch (e) {
    return date;
  }
}

String getFormattedDateHour(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = DateFormat.Hm();
    return format.format(d);
  }
}

String getFormattedDateHourMinSec(String date) {
  try {
    DateTime d = DateTime.parse(date);
    var format = DateFormat.Hms();
    return format.format(d.toUtc());
  } catch (e) {
    DateTime d = DateTime.now();
    var format = DateFormat.Hm();
    return format.format(d);
  }
}

String? getFormattedDateHourMinuteSecond() {
  var format = DateFormat.Hms();
  try {
    DateTime d = DateTime.now();
    return format.format(d.toUtc());
  } catch (e) {}
  return null;
}

String getFormattedNumber(int number, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = '${myLocale.languageCode}_${myLocale.countryCode!}';
  final oCcy = NumberFormat("###,###,###,###,###", val);

  return oCcy.format(number);
}

String getFormattedDouble(double number, BuildContext context) {
  Locale myLocale = Localizations.localeOf(context);
  var val = '${myLocale.languageCode}_${myLocale.countryCode!}';
  final oCcy = NumberFormat("###,###,###,###,##0.0", val);

  return oCcy.format(number);
}

String getFormattedAmount(String amount, BuildContext context) {
  assert(amount != null);
  Locale myLocale = Localizations.localeOf(context);
  var val = '${myLocale.languageCode}_${myLocale.countryCode!}';
  //pp('getFormattedAmount ----------- locale is  $val');
  final oCcy =  NumberFormat("#,##0.00", val);
  try {
    double m = double.parse(amount);
    return oCcy.format(m);
  } catch (e) {
    return amount;
  }
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

const lorem =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Odio eu feugiat pretium nibh ipsum consequat nisl. Dui sapien eget mi proin sed. Pellentesque id nibh tortor id aliquet lectus. Facilisis leo vel fringilla est. Orci dapibus ultrices in iaculis nunc sed. In fermentum et sollicitudin ac orci. Posuere ac ut consequat semper viverra nam libero. Ligula ullamcorper malesuada proin libero nunc. Dictum sit amet justo donec. Sem nulla pharetra diam sit amet nisl suscipit adipiscing. Libero volutpat sed cras ornare arcu dui vivamus arcu felis.'
    ' Aliquet risus feugiat in ante metus. Aliquet porttitor lacus luctus accumsan tortor posuere ac ut. Elementum tempus egestas sed sed risus pretium quam vulputate. Magna fermentum iaculis eu non. Dui faucibus in ornare quam viverra orci sagittis. Eu turpis egestas pretium aenean pharetra magna ac placerat. Risus in hendrerit gravida rutrum quisque non. Elit ullamcorper dignissim cras tincidunt. Cras ornare arcu dui vivamus arcu felis bibendum ut tristique. Gravida neque convallis a cras semper auctor neque vitae tempus. Eleifend mi in nulla posuere sollicitudin aliquam ultrices. Pulvinar pellentesque habitant morbi tristique senectus et netus et.'
    'Facilisis magna etiam tempor orci eu lobortis elementum. Ornare aenean euismod elementum nisi quis eleifend quam adipiscing vitae. Commodo viverra maecenas accumsan lacus vel facilisis volutpat. Maecenas pharetra convallis posuere morbi. Nibh venenatis cras sed felis eget velit aliquet sagittis. Viverra tellus in hac habitasse platea. Magna ac placerat vestibulum lectus mauris ultrices. Habitasse platea dictumst vestibulum rhoncus est pellentesque elit ullamcorper dignissim. Ut etiam sit amet nisl purus in. Eget sit amet tellus cras adipiscing enim eu turpis egestas. Blandit cursus risus at ultrices mi tempus imperdiet nulla malesuada. Nunc faucibus a pellentesque sit amet.'
    'Egestas dui id ornare arcu odio ut. Proin sagittis nisl rhoncus mattis rhoncus. Arcu cursus euismod quis viverra nibh cras. Mi proin sed libero enim sed faucibus turpis. Nisl condimentum id venenatis a condimentum. Ultrices in iaculis nunc sed augue. Cras semper auctor neque vitae tempus quam pellentesque nec. Neque aliquam vestibulum morbi blandit cursus. Faucibus interdum posuere lorem ipsum dolor sit. Fringilla est ullamcorper eget nulla facilisi etiam dignissim diam. Nulla aliquet enim tortor at. Ultricies mi quis hendrerit dolor magna eget est lorem. Sagittis purus sit amet volutpat consequat mauris nunc congue nisi. Lacus laoreet non curabitur gravida arcu. Neque convallis a cras semper auctor. Malesuada proin libero nunc consequat interdum varius sit amet mattis. Amet cursus sit amet dictum sit. Curabitur vitae nunc sed velit dignissim sodales ut eu. Molestie a iaculis at erat pellentesque adipiscing. Nisi quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus.';

abstract class SnackBarListener {
  onActionPressed(int action);
}