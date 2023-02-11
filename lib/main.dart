import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

final log = Logger(printer: PrettyPrinter(methodCount: 0));

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final repoProvider = Provider<Repo>((ref) {
  final storage = ref.watch(sharedPreferencesProvider);
  return Repo(storage);
});

class Repo {
  final SharedPreferences sharedPreferences;

  Repo(this.sharedPreferences) {
    log.i('(REPO) init');
  }

  String getString(String key) {
    return sharedPreferences.getString(key) ?? '';
  }

  Future<void> setString(String key, String value) {
    return sharedPreferences.setString(key, value);
  }
}

const kIsStorageKey = 'key';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const HomePage(),
    ),
  );
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repoProvider);
    final contr = TextEditingController(text: repo.getString(kIsStorageKey));
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: contr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your name',
                ),
              ),
              Expanded(
                  child: FloatingActionButton(
                onPressed: () async {
                  await repo.setString(kIsStorageKey, contr.text);
                },
                child: const Icon(Icons.save),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
