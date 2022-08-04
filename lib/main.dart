import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    return MaterialApp(
      title: 'Startup Name Generator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
        ),
        body: Center(
          child: RandomWords(),
        ),
      ),
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
  final Set<WordPair> _saved = new Set<WordPair>(); // 用来存储喜欢的单词
  final _biggerFont = const TextStyle(fontSize: 18);


  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: /*1*/ (context, i) {
        /** 奇数返回分割线 */
        if (i.isOdd) return const Divider(); /*2*/
        print(i);
        /** 计算单词数, 上面单奇数返回分割线了，所以到这里i都是偶数了，偶数除2向下取整就是单词的数量  */
        final index = i ~/ 2; /*3*/
        
        /** 滚动的index大于suggestions的长度时增加十条 */
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10)); /*4*/
        }

        final pair = _suggestions[index];
        final bool alreadySaved = _saved.contains(pair);

        return ListTile(
          title: Text(
            _suggestions[index].asPascalCase,
            style: _biggerFont,
          ),
          trailing: new Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onTap: () {
            setState(() {
              if (alreadySaved) {
                _saved.remove(pair);
              } else { 
                _saved.add(pair); 
              } 
            });
          },
        );
      },
    );
  }
}