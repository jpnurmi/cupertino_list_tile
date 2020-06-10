import 'package:flutter/cupertino.dart';
import 'package:cupertino_list_tile/cupertino_list_tile.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool dark = false;
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'CupertinoListTile',
      theme: CupertinoThemeData(
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('CupertinoListTile'),
          trailing: CupertinoSwitch(
            value: dark,
            onChanged: (value) => setState(() => dark = value),
          ),
        ),
        child: CupertinoScrollbar(
          child: ListView.builder(
            itemCount: 100,
            itemBuilder: (BuildContext context, int index) {
              final selected = index == selectedIndex;
              final enabled = index == 0 || index % 10 != 0;
              return CupertinoListTile(
                title: Text('CupertinoListTile #$index'),
                enabled: enabled,
                selected: selected,
                subtitle: Text(
                    'A ${selected ? 'selected' : !enabled ? 'disabled' : 'normal'} CupertinoListTile'),
                onTap: () => setState(() => selectedIndex = index),
              );
            },
          ),
        ),
      ),
    );
  }
}
