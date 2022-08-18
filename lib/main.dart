import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.yellow,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({ Key? key });

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final Set<WordPair> _saved = <WordPair>{}; // 用来存储喜欢的单词
  final _biggerFont = const TextStyle(fontSize: 18);
  var appBarTitleText  = Text('Random wrods list');

  final methodChannelBattery = MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';

  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();

    return Scaffold(
      appBar: AppBar(
        title: appBarTitleText,
        actions: <Widget>[
          ElevatedButton(
            child: Text("查看电池电量"),
            onPressed: _getBatteryLevel,
          ),
          IconButton(onPressed: _pushSaved, icon: const Icon(Icons.list)),
        ],
      ),
      body: Center(
        child: Stack(children: [
          Container(
            child: Row(children: [
              Text('电池电量:'),
              Text(_batteryLevel)
            ]),
          ),
          _buildSuggerstions(),
        ],)
      ),
    );
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      // invokeMethod('getBatteryLevel') 会回调 MethodCallHandler
      final int result = await methodChannelBattery.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    } on MissingPluginException catch (e) {
      print(e);
      batteryLevel = "plugin undefined";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  /** 主界面列表weiget */
  Widget _buildSuggerstions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        /** 奇数返回分割线 */
        if (i.isOdd) return const Divider();
        /** 计算单词数, 上面单奇数返回分割线了，所以到这里i都是偶数了，偶数除2向下取整就是单词的数量  */
        final index = i ~/ 2;
        
        /** 滚动的index大于suggestions的长度时增加十条 */
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        final pair = _suggestions[index];
        final bool alreadySaved = _saved.contains(pair);

        return ListTile(
          title: Text(
            _suggestions[index].asPascalCase,
            style: _biggerFont,
          ),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onTap: () => showDialog<String>(context: context, builder: (BuildContext context) => AlertDialog(
            title: const Text('提示'),
            content: Text(alreadySaved ? '确定要删除该收藏' : '确定要加入收藏?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, '取消'),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => {
                  setState(() {
                    appBarTitleText = Text('Current tap word is ${pair.asPascalCase}');
                    if (alreadySaved) {
                      _saved.remove(pair);
                    } else { 
                      _saved.add(pair); 
                    }
                  }),
                  Navigator.pop(context, '取消')
                },
                child: const Text('确定'),
              ),
            ],
          )),
        );
      },
    );
  }
  
  void _pushSaved() {

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        /** 通过_saved构建list */
        final Iterable<ListTile> tiles = _saved.map(
          (WordPair pair) {
            return ListTile(
              title: Text(
                pair.asPascalCase,
                style: _biggerFont
              ),
              onTap: () {
                setState(() {
                  appBarTitleText = Text(pair.asPascalCase);
                  // title = pair.asPascalCase;
                });
              },
            );
          },
        );

        /** 分割线 */
        final List<Widget> divided = ListTile
        .divideTiles(
          context: context,
          tiles: tiles,
        ).toList();

        return Scaffold(
          appBar: AppBar(
            title: appBarTitleText,
          ),
          body: ListView(children: divided),
        );
      })
    );
  }

}