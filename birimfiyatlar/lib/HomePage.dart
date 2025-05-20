import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'AuthService.dart';
import 'BookTree.dart';
import 'PozList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "token.env");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  static List<String> selectedBookCodes = [];

  static int selectedIndex = 0;

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  late String bookCodes;
  List<BookTree> books = [];
  List<int> selectedbooks = [];
  int count = 0;


  @override
  void initState() {
    super.initState();
    loadbookfromApi();
  }
  void toggleBookSelection(BookTree booktree){
    setState(() {
      booktree.isSelected = !booktree.isSelected!;
      if(booktree.isSelected!){
        if(!selectedbooks.contains(booktree.id)){
          selectedbooks.add(booktree.id!);
          count++;
        }
      }
      if(!booktree.isSelected!){
        if(selectedbooks.contains(booktree.id)){
          selectedbooks.remove(booktree.id);
        }
      }
      HomePage.selectedBookCodes = selectedbooks.map((id) => id.toString()).toList();

    });
  }

  Future<void> loadbookfromApi() async {
    final String? email = dotenv.env['EMAIL'];
    final String? password = dotenv.env['PASSWORD'];
    final AuthService authService = AuthService();
    final String? token = await authService.signInWithEmailAndPassword(
      email: email ?? "",
      password: password ?? "",
    );
    final Uri url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/workitem/treelist"
          "?Filter=%5B%22parentId%22%2C%22%3D%22%2Cnull%5D"
          "&bookTypeId=1",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data']['data'];

        final List<BookTree> fetchedBooks =
        dataList.map((e) => BookTree.fromJson(e)).toList();

        setState(() {
          books = fetchedBooks;

          for (final bookItem in books) {
            final idtoString = bookItem.id.toString();
            if (HomePage.selectedBookCodes.contains(idtoString)) {
              bookItem.isSelected = true;
            } else {
              bookItem.isSelected = false;
            }
          }
        });
      } else {
        print("Kitap listesi alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  final TextEditingController _searchController = TextEditingController();



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(flex: 2,),
              Text(
                'n.Birim Fiyat',
                textScaler: TextScaler.linear(3),
              ),
              const SizedBox(width: double.infinity, height: 50),
              Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      elevation: MaterialStateProperty.all(0.3),
                      backgroundColor: MaterialStateProperty.all(Color(0xFFF1F2F6)),
                      controller: _searchController,
                      hintText: 'Ara',
                      onSubmitted: (value) {
                        HomePage.selectedIndex = 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PozList(
                              selectedBookCodes: HomePage.selectedBookCodes,
                              SearchQuery: value,
                            ),
                          ),
                        );
                      },
                      trailing: [
                        IconButton(
                          onPressed: () {
                            HomePage.selectedIndex = 1;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PozList(
                                  selectedBookCodes: HomePage.selectedBookCodes,
                                  SearchQuery: _searchController.text,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.search),
                          color: Colors.black,
                        ),
                        IconButton(
                          onPressed: () async {
                            if (books.isEmpty) {
                              await loadbookfromApi();
                            }
                            if (!context.mounted) return;
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                              ),
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setStateModal) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      
                                      height: 600,
                                      padding: const EdgeInsets.all(16),
                                      child: books.isEmpty
                                          ? const Center(child: CircularProgressIndicator())
                                          : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Kitap Listesi',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: books.length,
                                              itemBuilder: (context, index) {
                                                final bookItem = books[index];
                                                return CheckboxListTile(
                                                  title: Text(bookItem.displayName ?? ''),
                                                  controlAffinity: ListTileControlAffinity.leading,
                                                  value: bookItem.isSelected,
                                                    onChanged: (val) {
                                                      setStateModal(() {
                                                        bookItem.isSelected = val!;
                                                        if (val) {
                                                          if (!selectedbooks.contains(bookItem.id)) {
                                                            selectedbooks.add(bookItem.id!);
                                                          }
                                                        } else {
                                                          selectedbooks.remove(bookItem.id);
                                                        }
                                                        HomePage.selectedBookCodes =
                                                            selectedbooks.map((id) => id.toString()).toList();
                                                      });
                                                    }
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          icon: Image.asset(
                            'assets/images/book.png',
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              IconButton(
                onPressed: () async {
                  await goToWebPage("https://www.novusyazilim.com/");
                },
                icon: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(
                height: 80,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> goToWebPage(String urlString) async {
    final Uri _url = Uri.parse(urlString);
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}