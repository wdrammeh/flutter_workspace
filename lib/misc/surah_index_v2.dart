import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(Application());
}

final appName = "Surah Index Exercise";
final Map<int, String> _index = {
  1: "Fatiha",
  2: "Baqarah",
  3: "Ali Imran",
  4: "Nisa",
  5: "Maidah",
  6: "Anham",
  7: "Ahraf",
  8: "Anfal",
  9: "Tawbah",
  10: "Yunus",
  11: "Hud",
  12: "Yusuf",
  13: "Rahd",
  14: "Ibrahim",
  15: "Hijr",
  16: "Nahl",
  17: "Isra",
  18: "Kahf",
  19: "Maryam",
  20: "Ta-Ha",
  21: "Anbiyah",
  22: "Hajj",
  23: "Muhminun",
  24: "Nur",
  25: "Furqan",
  26: "Shuharah",
  27: "Naml",
  28: "Qasas",
  29: "Ankabut",
  30: "Rum",
  31: "Luqman",
  32: "Sajdah",
  33: "Ahzab",
  34: "Saba",
  35: "Fatir",
  36: "Ya-Seen",
  37: "Saffat",
  38: "Saad",
  39: "Zumur",
  40: "Ghafir",
  41: "Fussilat",
  42: "Shurah",
  43: "Zukhruf",
  44: "Dukhan",
  45: "Jasiyah",
  46: "Ahqaf",
  47: "Muhammad",
  48: "Fath",
  49: "Hujurat",
  50: "Qaf",
  51: "Dhariyat",
  52: "Tur",
  53: "Najm",
  54: "Qamar",
  55: "Rahman",
  56: "Waqihah",
  57: "Hadid",
  58: "Mujadilah",
  59: "Hashr",
  60: "Mumtahana",
  61: "Saff",
  62: "Jumuhah",
  63: "Munafiqun",
  64: "Taghabun",
  65: "Talaq",
  66: "Tahrim",
  67: "Mulk",
  68: "Qalam", // Nuhn
  69: "Haqqah",
  70: "Mahrij",
  71: "Nuh",
  72: "Jin",
  73: "Muzzammil",
  74: "Muddathir",
  75: "Qiyamah",
  76: "Insan", // Dhar
  77: "Mursalat",
  78: "Nabah",
  79: "Naziat",
  80: "Abasa",
  81: "Takwir",
  82: "Infitar",
  83: "Mutaffifin",
  84: "Inshiqaq",
  85: "Buruj",
  86: "Tariq",
  87: "Ahla",
  88: "Ghasiyah",
  89: "Fajr",
  90: "Balad",
  91: "Shams",
  92: "Layl",
  93: "Duhaa",
  94: "Sharha",
  95: "Tin",
  96: "Alaq", // Iqrah
  97: "Qadr",
  98: "Bayyinah",
  99: "Zalzalah",
  100: "Adiyat",
  101: "Qhariah",
  102: "Takathur",
  103: "Asr",
  104: "Humazah",
  105: "Fil",
  106: "Quraysh",
  107: "Mahun",
  108: "Kawthar",
  109: "Kafirun",
  110: "Nasr",
  111: "Masad", // Lahab
  112: "Ikhlas",
  113: "Falaq",
  114: "Nas"
};

class Application extends StatelessWidget {
  Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  State<Homepage> createState() {
    return _HomepageState();
  }
}

class _HomepageState extends State<Homepage> {
  int _counter = 1;
  int _correct = 0;
  int _surah = Random().nextInt(_index.length) + 1;
  final List<int> _taken = [];
  late List<int> _options;
  
  @override
  void initState() {
    super.initState();
    _options = _getOptions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _getSurah({add = true}) {
    assert(_taken.length < _index.length);
    
    var i = Random().nextInt(_index.length) + 1;
    if (_taken.contains(i)) {
      return _getSurah();
    } else {
      if (add == true) {
        _taken.add(i);
      }
      return i;
    }
  }
  
  List<int> _getOptions() {
    final option2 = _getSurah(add: false);
    
    // final option3 = _getSurah(except: <int>[option2], add: false);
    var option3 = Random().nextInt(_index.length) + 1;
    while (option3 == _surah || option3 == option2) {
      option3 = Random().nextInt(_index.length) + 1;
    }

    // final option4 = _getSurah(except: <int>[option2, option3], add: false);
    var option4 = Random().nextInt(_index.length) + 1;
    while (option4 == _surah || option4 == option2 || option4 == option3) {
      option4 = Random().nextInt(_index.length) + 1;
    }
    
    return [_surah, option2, option3, option4];
  }

  void _eval(int surah) {
    final bool correct = surah == _surah;
    final String answer;
    if (correct) {
      answer = "True";
      _correct++;
    } else {
      answer = "False";
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_counter > _index.length) {
      // Get a copy of the score somehow... because Navigator.push is a Future
      final int mark = _correct;
      
      setState(() {
        _taken.clear();
        _counter = 1;
        _correct = 0;
        _surah = _getSurah();
        _options = _getOptions();
      });
      
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CompletedActivity(mark);
        }),
      );
    } else {
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: correct ? Theme.of(context).primaryColor : Colors.red,
        content: Text(
          answer,
          style: TextStyle(color: Theme.of(context).colorScheme.surface),
        ),
        action: SnackBarAction(
          textColor: Theme.of(context).colorScheme.surface,
          label: 'Close',
          onPressed: () {},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      setState(() {
        _counter++;
        _surah = _getSurah();
        _options = _getOptions();
      });
    }
  }
  
  Widget _optionTile(val) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 64, vertical: 4),
      child: ListTile(
        title: Center(child: Text(val.toString(),),),
        textColor: Colors.white,
        onTap: () {
          _eval(val);
        },
      ),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(50)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _options.shuffle();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        actions: [
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 16),
            icon: Icon(Icons.info_outlined),
            tooltip: 'Learn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return LearnActivity();
                }),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 32),
              child: Text(
                "$_counter. What's the index of Surah ${_index[_surah]}?",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Column(
              children: [
                _optionTile(_options[0]),
                _optionTile(_options[1]),
                _optionTile(_options[2]),
                _optionTile(_options[3]),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text("Muhammed W Drammeh"),
              ),
            ],
          )),
    );
  }
}

class CompletedActivity extends StatelessWidget {
  final int _mark;

  CompletedActivity(this._mark, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Quiz completed",
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Your score: ${_mark}/${_index.length}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Play again"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearnActivity extends StatelessWidget {
  LearnActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Surah Index"),
        ),
        body: ListView.builder(
          itemCount: _index.length,
          itemBuilder: (context, i) {
            final int j = i + 1;
            return ListTile(
              title: Text(
                "$j. ${_index[j]}",
              ),
              onTap: () {
                
              },
            );
          },
        ),
    );
  }
}
