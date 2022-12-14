import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/people_list.dart';
import 'models/pages_provider.dart';
import 'models/auth_provider.dart';
import 'screens/screen_swapper.dart';
import 'screens/details_screen.dart';
import 'screens/tabs_screen.dart';
import 'utils/app_routes.dart';

main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()
        ),
        ChangeNotifierProxyProvider<AuthProvider, PeopleList>(
          create: (_) => PeopleList('', ''),
          update: (_, auth, peopleList) => PeopleList(
            auth.token ?? '',
            auth.uid ?? ''
          )
        ),
        ChangeNotifierProxyProvider<PeopleList, PagesProvider>(
          create: (_) => PagesProvider(), 
          update:(_, peopleList, pages) => pages!..update(peopleList)
        ),
      ],
      child: MaterialApp(
        title: 'SWAPI Info',
        theme: ThemeData(
          primaryColor: Colors.black, 
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.amber,
            onSecondary: Colors.yellow,
            tertiary: Colors.black54
          ),
          canvasColor: Colors.black,
          fontFamily: 'Raleway',
          textTheme: ThemeData.dark().textTheme.copyWith(
            titleMedium: const TextStyle(
              fontSize: 20,
              fontFamily: 'RobotoCondensed',
              color: Colors.black
            )
          )
        ),
        routes: {
          AppRoutes.authOrHomeSwapper: (ctx) => const ScreenSwapper(),
          AppRoutes.personDetails: (ctx) => const DetailsScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => const TabsScreen(),
          );
        },
      ),
    );
  }
}