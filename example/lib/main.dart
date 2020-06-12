import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show FlutterLogo;
import 'package:provider/provider.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => ValueNotifier<Brightness>(Brightness.light),
        child: ExampleApp(),
      ),
    );

CupertinoNavigationBar buildNavigationBar(String title) {
  return CupertinoNavigationBar(
    middle: Text(title),
    trailing: Consumer<ValueNotifier<Brightness>>(
      builder: (context, brightness, child) {
        return CupertinoSwitch(
          value: brightness.value == Brightness.dark,
          onChanged: (value) =>
              brightness.value = value ? Brightness.dark : Brightness.light,
        );
      },
    ),
  );
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ValueNotifier<Brightness>>(
      builder: (context, brightness, child) {
        return CupertinoApp(
          title: 'CupertinoListTile',
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(brightness: brightness.value),
          routes: {
            '/': (_) => HomePage(),
            '/one-line': (_) => TilePage(
                  title: 'One-line',
                  tileBuilder: (BuildContext context, String title) {
                    return CupertinoListTile(title: Text(title));
                  },
                ),
            '/one-leading': (_) => TilePage(
                  title: 'One-line with leading widget',
                  tileBuilder: (BuildContext context, String title) {
                    return CupertinoListTile(
                      leading: FlutterLogo(),
                      title: Text(title),
                    );
                  },
                ),
            '/one-trailing': (_) => TilePage(
                  title: 'One-line with trailing widget',
                  tileBuilder: (BuildContext context, String title) {
                    return CupertinoListTile(
                      title: Text(title),
                      trailing: Icon(CupertinoIcons.ellipsis),
                    );
                  },
                ),
            '/one-both': (_) => TilePage(
                  title: 'One-line with both widgets',
                  tileBuilder: (BuildContext context, String title) {
                    return CupertinoListTile(
                      leading: FlutterLogo(),
                      title: Text(title),
                      trailing: Icon(CupertinoIcons.ellipsis),
                    );
                  },
                ),
            '/two-line': (_) => TilePage(
                  title: 'Two-line',
                  tileBuilder: (BuildContext context, String title) {
                    return CupertinoListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text(title),
                      subtitle: Text('Second line...'),
                    );
                  },
                ),
            '/three-line': (_) => TilePage(
                  title: 'Two-line',
                  tileBuilder: (BuildContext context, String title) {
                    return CupertinoListTile(
                      leading: FlutterLogo(size: 72.0),
                      title: Text('Three-line ListTile'),
                      subtitle: Text('Lorem ipsum\ndolor sit amet'),
                      isThreeLine: true,
                    );
                  },
                ),
          },
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: buildNavigationBar('CupertinoListTile'),
      child: CupertinoScrollbar(
        child: ListView(
          children: [
            CupertinoListTile(
              title: Text('One-line'),
              onTap: () => Navigator.of(context).pushNamed('/one-line'),
            ),
            CupertinoListTile(
              title: Text('One-line with leading widget'),
              onTap: () => Navigator.of(context).pushNamed('/one-leading'),
            ),
            CupertinoListTile(
              title: Text('One-line with trailing widget'),
              onTap: () => Navigator.of(context).pushNamed('/one-trailing'),
            ),
            CupertinoListTile(
              title: Text('One-line with both widgets'),
              onTap: () => Navigator.of(context).pushNamed('/one-both'),
            ),
            CupertinoListTile(
              title: Text('Two-line'),
              onTap: () => Navigator.of(context).pushNamed('/two-line'),
            ),
            CupertinoListTile(
              title: Text('Three-line'),
              onTap: () => Navigator.of(context).pushNamed('/three-line'),
            ),
          ],
        ),
      ),
    );
  }
}

typedef TileBuilder = Widget Function(BuildContext context, String title);

class TilePage extends StatelessWidget {
  final String title;
  final TileBuilder tileBuilder;

  TilePage({Key key, this.title, this.tileBuilder});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: buildNavigationBar(title),
      child: CupertinoScrollbar(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (BuildContext context, int index) {
            return tileBuilder(context, '$title #$index');
          },
        ),
      ),
    );
  }
}
