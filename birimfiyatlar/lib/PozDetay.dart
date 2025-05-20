import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AnalizFiyat.dart';
import 'AuthService.dart';
import 'Book.dart';
import 'BirimFiyat.dart';
import 'Poz.dart';
import 'AnalizPage.dart';
import 'AnalizPoz.dart';
import 'Unit.dart';
import 'workItemRecursive.dart';

class PozDetail extends StatefulWidget {
  final Poz selectedPoz;
  const PozDetail({Key? key, required this.selectedPoz}) : super(key: key);

  @override
  State<PozDetail> createState() => _PozDetailState();
}

class _PozDetailState extends State<PozDetail> {
  bool _isLoading = false;

  Map<int, String?> typemap = {
    1: 'Malzeme Bileşenleri',
    2: 'Montaj Bileşenleri',
    3: 'Malzeme',
    4: 'İşçilik',
    5: 'Makine ve Ekipman',
    6: 'Taşıma',
    7: 'Yönetim',
    8: 'Foraj',
    9: 'Diğer',
  };
  Map<int, String?> kindmap = {
    1: 'İş Kalemi',
    2: 'Taşıma',
    3: 'Prosedür',
    4: 'Açıklama',
  };

  bool isclickable = false;

  List<Book> books = [];
  List<AnalizPoz> Analizler = [];
  List<BirimFiyat> fiyatlar = [];
  List<Unit> units = [];
  List<AnalizPoz> AnalyzePozList = [];
  List<WorkItemRecursive> workItemRecursiveList = [];

  List<AnalizPoz> typebuilderList = [];
  List<AnalizPoz> kindbuilderList = [];
  List<AnalizPoz> formulaList = [];

  String? _token;

  final ScrollController _detailScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    await _initToken();

    if (_token != null) {
      await loadBooksFromApi();
      await loadPriceFromApi();
      await loadUnitsFromApi();
      await _loadinitstate();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadinitstate() async {
    final List<AnalizPoz> analizData = await loadAnalizDataFromApi(widget.selectedPoz.id!);
    AnalyzePozList = await getAnalyzePoz(analizData);
    await loadWorkItemRecursiveFromApi(widget.selectedPoz.id!);
  }

  String? selecttype(AnalizPoz poz) {
    return typemap[poz.analysisTypeId];
  }

  String? selectkind(AnalizPoz poz) {
    return kindmap[poz.analysisKindId];
  }

  Future<void> _initToken() async {
    final String? email = dotenv.env['EMAIL'];
    final String? password = dotenv.env['PASSWORD'];
    final authService = AuthService();
    _token = await authService.signInWithEmailAndPassword(
      email: email ?? "",
      password: password ?? "",
    );
  }

  Future<void> loadBooksFromApi() async {
    final url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/book/lookup?bookTypeId=1",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data']['data'];
        final List<Book> fetchedBooks = dataList.map((e) => Book.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          books = fetchedBooks;
        });
      } else {
        print("Kitap listesi alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      print("Hata oluştu (Book): $e");
    }
  }

  Future<void> loadPriceFromApi() async {
    final int workItemId = widget.selectedPoz.id!;

    final url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/workitemprice/getprices/$workItemId",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data']['data'];
        final List<BirimFiyat> fetchedPrices = dataList.map((e) => BirimFiyat.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          fiyatlar = fetchedPrices;
        });
      } else {
        print("Birim fiyat alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      print("Hata oluştu (Fiyat): $e");
    }
  }

  Future<void> loadWorkItemRecursiveFromApi(int id) async {
    final url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/workitem/getworkitemsrecursive/$id",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] as List<dynamic>;
        if (!mounted) return;
        setState(() {
          workItemRecursiveList = dataList.map((e) => WorkItemRecursive.fromJson(e)).toList();
        });
      } else {
        print("Unit listesi alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      print("$e");
    }
  }

  Future<List<AnalizBirimFiyat>> getPricesFromAnalyze(int analysisItemId) async {
    List<AnalizBirimFiyat> tempList = [];
    for (var item in workItemRecursiveList) {
      if (item.id == analysisItemId && item.workItemPrices != null) {
        tempList.addAll(item.workItemPrices!);
      }
    }
    return tempList;
  }

  Future<List<AnalizPoz>> getAnalysesFromAnalyze(int id) async {
    List<AnalizPoz> tempList = [];
    for (var item in workItemRecursiveList) {
      if (item.workItemAnalysis != null &&
          item.workItemAnalysis!.isNotEmpty &&
          item.id == id) {
        for (var data in item.workItemAnalysis!) {
          tempList.add(data);
        }
      }
    }
    return tempList;
  }

  Future<void> loadUnitsFromApi() async {
    final url = Uri.parse(
      "https://developer.novusyazilim.com/cmn.wa/api/unitCode",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data']['data'];
        final List<Unit> fetchedunits = dataList.map((e) => Unit.fromJson(e)).toList();
        if (!mounted) return;
        setState(() {
          units = fetchedunits;
        });
      } else {
        print("Unit listesi alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      print("$e");
    }
  }

  Future<List<AnalizPoz>> loadAnalizDataFromApi(int workItemId) async {
    final url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/workitemanalysis/getworkitemsanalyzes/$workItemId",
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data']['data'];
        return dataList.map((json) => AnalizPoz.fromJson(json)).toList();
      } else {
        throw Exception("Analiz verisi alınamadı. Hata kodu: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Analiz verisi çekilirken hata oluştu: $e");
    }
  }

  Future<List<AnalizPoz>> getAnalyzePoz(List<AnalizPoz> AnalyzeList) async {
    for (int i = 0; i < AnalyzeList.length; i++) {
      if (AnalyzeList[i].analysisTypeId != null) {
        typebuilderList.add(AnalyzeList[i]);
      }
      if (AnalyzeList[i].analysisKindId != null &&
          AnalyzeList[i].analysisTypeId == null &&
          AnalyzeList[i].analysisItemFullCode != '') {
        kindbuilderList.add(AnalyzeList[i]);
      }
      if (AnalyzeList[i].analysisItemFullCode == '') {
        formulaList.add(AnalyzeList[i]);
      }
    }
    return AnalyzeList;
  }

  bool is_clickable() {
    if (typebuilderList.isNotEmpty || formulaList.isNotEmpty || kindbuilderList.isNotEmpty) {
      isclickable = true;
    }
    return isclickable;
  }

  String? find_unit(int id) {
    for (int i = 0; i < units.length; i++) {
      if (id == units[i].id) {
        return units[i].code;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          title: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Poz Detay'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: const Color(0xFFF1F2F6),
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: ClipOval(
              child: Container(
                width: 50,
                height: 50,
                color: Colors.transparent,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const SweepGradient(
                      colors: [
                        Color(0xFF561F83),
                        Color(0xFF643888),
                        Color(0xFF5F4673),
                      ],
                      tileMode: TileMode.mirror,
                    ).createShader(bounds);
                  },
                  child: const CircularProgressIndicator(
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final pozItem = widget.selectedPoz;
    final int bookIndex = books.indexWhere((b) => b.code == pozItem.bookCode);
    String kurumAdi = "";
    if (bookIndex != -1) {
      kurumAdi = books[bookIndex].organisationNames ?? '';
    }
    final List<BirimFiyat> filteredPrices = fiyatlar;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: const Text('Poz Detay'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFFF1F2F6),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _detailScrollController,
                      padding: const EdgeInsets.only(right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Poz No: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: pozItem.fullCode,
                                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Tanım: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: pozItem.name,
                                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Birim: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: pozItem.unitName,
                                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Kurum: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: kurumAdi,
                                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'ID: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${pozItem.id}',
                                  style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Birim Fiyatlar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Table(
                            border: TableBorder.all(color: Colors.black),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(2),
                            },
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(color: Color(0xFFF1F2F6)),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Tarih', textAlign: TextAlign.center),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Birim Fiyat', textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                              ...filteredPrices.map((price) {
                                final String dateStr = price.effectiveDate!.split('T').first;
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(dateStr, textAlign: TextAlign.center),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        price.price.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Yapım Şartları',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: Text(pozItem.depiction ?? '', style: const TextStyle(fontStyle: FontStyle.normal)),
                          ),
                          const SizedBox(height: 16),
                          if (typebuilderList.isNotEmpty ||
                              formulaList.isNotEmpty ||
                              kindbuilderList.isNotEmpty) ...[
                            const Text('Analiz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: typebuilderList.length,
                              itemBuilder: (context, index) {
                                final AnalyzeItem = typebuilderList[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selecttype(AnalyzeItem).toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: InkWell(
                                        onTap: is_clickable()
                                            ? () async {
                                          try {
                                            AnalizPoz selectedPoz = AnalyzeItem;
                                            List<AnalizBirimFiyat> analyzePrices =
                                            await getPricesFromAnalyze(AnalyzeItem.analysisItemId!);
                                            List<AnalizPoz> analyzeList =
                                            await getAnalysesFromAnalyze(AnalyzeItem.analysisItemId!);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Analizpage(
                                                  selectedAnalizPoz: selectedPoz,
                                                  selectedPozUnit: find_unit(AnalyzeItem.unitId!),
                                                  AnalyzeFiyatlar: analyzePrices,
                                                  workItemRecursive: workItemRecursiveList,
                                                  AnalyzeList: analyzeList,
                                                ),
                                              ),
                                            );
                                          } catch (e) {}
                                        }
                                            : null,
                                        child: Card(
                                          color: const Color(0xFFF1F2F3),
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(color: Colors.black54, width: 1),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Poz No: ${AnalyzeItem.analysisItemFullCode ?? ''}'),
                                                      Text(
                                                        'Poz Tanımı: ${AnalyzeItem.definition ?? ''}',
                                                        softWrap: true,
                                                        maxLines: 2,
                                                      ),
                                                      Text('Birim: ${find_unit(AnalyzeItem.unitId!)}'),
                                                      Text('Miktar: ${AnalyzeItem.quantity ?? ''}'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // FORMÜL
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: formulaList.length,
                              itemBuilder: (context, index) {
                                final AnalyzeItem = formulaList[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Card(
                                        color: const Color(0xFFF1F2F3),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(color: Colors.black54, width: 1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Poz Tanımı: ${AnalyzeItem.definition ?? ''}',
                                                      softWrap: true,
                                                    ),
                                                    Text('Miktar: ${AnalyzeItem.quantity ?? ''}'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: kindbuilderList.length,
                              itemBuilder: (context, index) {
                                final AnalyzeItem = kindbuilderList[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectkind(AnalyzeItem).toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: InkWell(
                                        onTap: is_clickable()
                                            ? () async {
                                          try {
                                            AnalizPoz selectedPoz = AnalyzeItem;
                                            List<AnalizBirimFiyat> analyzePrices =
                                            await getPricesFromAnalyze(AnalyzeItem.analysisItemId!);
                                            List<AnalizPoz> analyzeList =
                                            await getAnalysesFromAnalyze(AnalyzeItem.analysisItemId!);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Analizpage(
                                                  selectedAnalizPoz: selectedPoz,
                                                  selectedPozUnit: find_unit(AnalyzeItem.unitId!),
                                                  AnalyzeFiyatlar: analyzePrices,
                                                  workItemRecursive: workItemRecursiveList,
                                                  AnalyzeList: analyzeList,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            print("Analiz verisi çekilemedi: $e");
                                          }
                                        }
                                            : null,
                                        child: Card(
                                          color: const Color(0xFFF1F2F3),
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(color: Colors.black54, width: 1),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Poz No: ${AnalyzeItem.analysisItemFullCode ?? ''}'),
                                                      Text(
                                                        'Poz Tanımı: ${AnalyzeItem.definition ?? ''}',
                                                        softWrap: true,
                                                        maxLines: 2,
                                                      ),
                                                      Text('Birim: ${find_unit(AnalyzeItem.unitId!)}'),
                                                      Text('Miktar: ${AnalyzeItem.quantity ?? ''}'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -5,
                      top: 0,
                      bottom: 0,
                      child: Scrollbar(
                        controller: _detailScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 50,
                        radius: const Radius.circular(6),
                        child: Container(width: 0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
