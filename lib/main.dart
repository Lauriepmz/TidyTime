import 'package:tidytime/utils/all_imports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TimeProportionAdapter());
  Hive.registerAdapter(TimeAllocationAdapter());
  Hive.registerAdapter(RoomSelectedAdapter());
  Hive.registerAdapter(SelectedTaskAdapter());
  Hive.registerAdapter(QuizzResultsAdapter());
  Hive.registerAdapter(TemporaryTaskTimerLogAdapter());

  // Initialize Hive boxes
  await HiveBoxManager.instance.initializeBoxes();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TimerService timerService = TimerService(); // Instance centrale de TimerService

    return MultiProvider(
      providers: [
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<TimerService>(create: (_) => timerService),
        BlocProvider<SessionBloc>(
          create: (context) => SessionBloc(
            context.read<TaskService>(),
            context.read<TimerService>(),
          ),
        ),
        BlocProvider<TaskPlanningBloc>(
          create: (_) => TaskPlanningBloc(),
        ),
        ChangeNotifierProvider<LanguageProvider>(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.white),
              ),
            ),
            locale: Locale(languageProvider.currentLanguage), // Définit la langue actuelle
            supportedLocales: AppLocalizations.supportedLocales, // Langues supportées
            localizationsDelegates: const [
              AppLocalizations.delegate, // Traductions générées automatiquement
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (context) => const MainPage(),
                  );
                case '/timer':
                  return MaterialPageRoute(
                    builder: (context) {
                      final mainPageState = context.findAncestorStateOfType<MainPageState>();

                      if (mainPageState != null) {
                        return CleaningSessionPage(
                          onHideFloatingTimer: mainPageState.hideFloatingTimer,
                          onShowFloatingTimer: mainPageState.showFloatingTimer,
                          modifiedTasks: [],
                          timerService: context.read<TimerService>(),
                        );
                      } else {
                        return const Scaffold(
                          body: Center(
                            child: Text('MainPageState not found'),
                          ),
                        );
                      }
                    },
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const Scaffold(
                      body: Center(
                        child: Text('Page not found'),
                      ),
                    ),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
