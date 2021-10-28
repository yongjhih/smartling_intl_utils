# Smartling Intl Utils for Flutter


## Usage

First of all, Place Smartling json translations into the `i18n/` folder.

Run the following command:

```
flutter pub run smartling_intl_utils:generate
```

See the generated files:

```
lib/l10n/intl_*.arb
lib/generated/
              ├── intl
              │   ├── messages_all.dart
              │   ├── messages_en.dart
              ...
              │   ├── messages_zh_CN.dart
              │   └── messages_zh_TW.dart
              └── l10n.dart
```


Once initialized with the specific locale by the following code in somewhere:

```dart
await S.load(Locale("en"))
```

We can now use the translations:

```dart
Text(S.current.app_name)
```

For example:

```dart
FutureBuilder(
  future: S.load(Locale("en")),
  builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
     ? Text(S.current.app_name) : Container()
);
````

## Usage2 of Flutter Intl Delegation

```dart
MaterialApp(
  localizationsDelegates: <LocalizationsDelegate>[
    S.delegate,
  ],
  supportedLocales: S.delegate.supportedLocales,
  ...
  routes: <String, WidgetBuilder>{
    '/': (context) => Text(S.of(context).app_name),
  },
)
```

