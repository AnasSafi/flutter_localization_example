import 'package:flutter/material.dart';
import 'package:flutter_localization/config/app_config.dart';
import 'package:flutter_localization/services/translation_service.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  final BehaviorSubject<Locale?> notifierLocale;
  
  const HomeScreen({Key? key, required this.notifierLocale}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.of(context)!.translate('hello')),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownButton(
              dropdownColor: Colors.grey[200],
              style: TextStyle(
                color: Colors.black,
                backgroundColor: Colors.grey[200],
              ),
              onChanged: (v) => widget.notifierLocale.add(Locale(v.toString(), "")),
              value: TranslationService.currentLocale(context),
              items: List.generate(
                  AppConfig.supportedLanguage.length,
                      (index) => DropdownMenuItem(
                        value: AppConfig.supportedLanguage[index],
                        child: Text(AppConfig.supportedLanguage[index])
                      )
              ),
            )
          ],
        ),
      ),
    );
  }
}
