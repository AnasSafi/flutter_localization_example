import 'package:flutter/material.dart';
import 'package:flutter_localization/config/app_config.dart';
import 'package:flutter_localization/screens/home_screen.dart';
import 'package:flutter_localization/services/translation_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyMain());
}

class MyMain extends StatefulWidget {
  const MyMain({Key? key}) : super(key: key);

  @override
  State<MyMain> createState() => _MyMainState();
}

class _MyMainState extends State<MyMain> {
  final BehaviorSubject<Locale?> _notifierLocale = BehaviorSubject<Locale?>();
  Future? _futureFun;
  Locale _currentLocale = const Locale(AppConfig.defaultLanguage, '');

  @override
  void initState() {
    super.initState();

    _futureFun = _initData();

    // listen to change of interface language
    _notifierLocale.stream.listen((Locale? locale) async {
      if (locale != null && (locale.languageCode != _currentLocale.languageCode)) {
        final prefs = await SharedPreferences.getInstance();
        String newLocale = locale.languageCode;
        await prefs.setString('appLocale', newLocale);
        setState(() {
          _currentLocale = locale;
        });
      }
    });
  }

  @override
  void dispose() {
    _notifierLocale.close();
    super.dispose();
  }

  Future<bool>? _initData() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastAppLocaleCode = prefs.getString('appLocale');
    if (lastAppLocaleCode != null) {
      _currentLocale = Locale(lastAppLocaleCode, '');
    }
    return true;
  }

  List<Locale> getSupportedLocales() {
    List<Locale> locales = [];
    for (var element in AppConfig.supportedLanguage) {
      locales.add(Locale(element, ''));
    }
    return locales;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureFun,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: _currentLocale.languageCode == "ar" ? "إسم التطبيق" : 'App Name',
            locale: _currentLocale,
            localizationsDelegates: const [
              TranslationService.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: getSupportedLocales(),
            routes: <String,WidgetBuilder>{
              HomeScreen.routeName :(BuildContext context)=> HomeScreen(notifierLocale: _notifierLocale),
            },
            initialRoute: HomeScreen.routeName,
          );
        }
        else if (snapshot.hasError) {
          return Container();  // here return your ErrorScreen widget
        }else {
          return Container(); // here return your SplashScreen widget
        }
      },
    );
  }
}

