import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*
 Consumer

  Controlling build() cost
  Consumer widget provides more specific rebuilds that improves performance.
  Bob the builder

*

* state Management 에는 Ephemeral 과 App 이 있다.
* Ephemeral 은 local state 에 관련된거다.
* App 은 Global state 에 관련된거다.
* 1. 공유하고 싶은 클래스 생성
* 2. 이 클래스를 Provider 을 통해서 공유
* 3. Provider.of<xxx>(context) 를 통해서 값을 사용
 */
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print("MyApp building");
    return
      ChangeNotifierProvider(
        create: (context) => ColourNotifier(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: ChangeNotifierProvider(
              create: (context) => CounterChangeNotifier(),
              child: const MyHomePage(title: 'Flutter Demo Home Page')),
        ),
      );
  }
}

class ColourNotifier with ChangeNotifier {
  bool _isRed = true;

  bool get isRed => _isRed;
  String tempStringForSelector = "임시";

  void switchColour() {
    _isRed = !_isRed;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    //var counterChangeNotifier = Provider.of<CounterChangeNotifier>(context); // 객체 만들었고.. 그객체를 위에서 사용한다고 했고
    // 여기서 변수로 받았다. 그렇지만 여기가 있어서 build 할 때마다 계속 하위에 있는것들이 전부 다 다시 빌드가 되는거지.. 그래서 // TODO
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Selector<ColourNotifier, bool>(
              selector: (context, colorNotifier) {
                return colorNotifier.isRed;
              },
              builder: (context, value, child) {
                return RedBox(isRed: value, child: child,); // 여기서 child 를 빼니깐 아예 child 를 패스해버리고 안찍어버리네..
              },
              child:  Consumer<CounterChangeNotifier>(
                  builder: (context, value, child) => CounterNumber(number : value.counter)),
              /*
               what's going on here?
               The child widget passed to Consumer is built on it own, outside of the builder callback.
               It is then passed into the builder as it's third argument.
               While this API may look a little wonky, it's pretty impressive.
               It allows the child widget to go on living', without being rebuilt,
               while all the widgets defined in the builder callback do get rebuilt. Wow.

                Again, the API might seem confusing, because it looks like the consumer now has two properties
                that build the widget tree below this Consumer.
                But, once you get used to looking at this, it's not a big deal. And totally worth the benefits.
               */
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<ColourNotifier>(context, listen: false).switchColour();
          Provider.of<CounterChangeNotifier>(context, listen: false).increment();
        },
        // 괭장히 중요한 부분이다. 내가 만든 클래스의 함수를 실행시킬때 값이 변경되는건 궁금하지 않고 그냥 함수를 받아오고 싶을 때
        // listen : false 로 세팅해준다.
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CounterNumber extends StatelessWidget {
  final int? number;
  const CounterNumber({Key? key, required this.number}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    print('CounterNumber building');
    return Text(
      number.toString(),
      style: Theme.of(context).textTheme.headline4,
    );
  }
}

class RedBox extends StatelessWidget {
  final Widget? child;
  final bool? isRed;
  const RedBox ({Key? key, this.child, this.isRed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('RedBox building');
    return Container( // 조건문
      color: isRed ?? true ? Colors.redAccent : Colors.blue,
      // ?? null 이면 true 를 헣고 true 이면
      width: 50,
      height: 50,
      child: Center(child: child,),
    ); // 잘봐라. return 문에는 항상 세미콜론을 넣어야 한다.
  }
}

class CounterChangeNotifier with ChangeNotifier { // setState 대신에 사용할 수 있다.
  int _counter = 0;
  int get counter => _counter;
  increment() {
    _counter++;
    notifyListeners();
  }
}
