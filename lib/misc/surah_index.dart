import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(Application());
}

final Map<int, String> _surahIndex = {
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
      title: 'Surah Index Quiz',
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
  int? _surah;
  final List<int> _taken = [];
  final fieldController = TextEditingController();
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    _surah = _getSurah;
    focusNode = FocusNode();
  }
  
  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.
    fieldController.dispose();
    focusNode.dispose();
  }

  // Todo refer
  int get _getSurah {
    var i = Random().nextInt(_surahIndex.length) + 1;
    if (_taken.contains(i)) {
      return _getSurah;
    } else {
      _taken.add(i);
      return i;
    }
  }
  
  void _eval() {
    final val = fieldController.text;
    print(val);
    final String answer;
    if (val == "$_surah") {
      answer = "True";
      _correct++;
    } else {
      answer = "False";
    }
    // final answer = "$_surah" == val ? "True" : "False";
    final snackBar = SnackBar(
      content: Text(
        answer,
        style: TextStyle(
            color: Theme.of(context).colorScheme.surface),
      ),
      action: SnackBarAction(
        textColor: Theme.of(context).colorScheme.surface,
        label: 'Close',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    final String mark = _correct.toString(); // Because showDialog is a Future call...
    if (_counter > _surahIndex.length) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Text(
                  "Quiz ended. Your score: $mark/${_surahIndex.length}."));
        },
      );
      // if (kDebugMode) {
      //   print(_taken);
      // }
      setState(() {
        _correct = 0;
        _counter = 1;
        _taken.clear();
        _surah = _getSurah;
        fieldController.clear();
      });
    } else {
      setState(() {
        _counter++;
        _surah = _getSurah;
        fieldController.clear();
        focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surah Index Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "By Muhammed W Drammeh",
                style: Theme.of(context).textTheme.headline6,
                // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "$_counter. What's the index of Surah ${_surahIndex[_surah]}:",
              ),
              TextField(
                // Todo use number field
                controller: fieldController,
                focusNode: focusNode,
                onSubmitted: (text) {
                  _eval();
                },
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  child: Text("Done"),
                  onPressed: _eval,
                ),
              ),
            ]),
      ),
    );
  }
}
