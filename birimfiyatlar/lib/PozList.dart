import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'BookTree.dart';
import 'HomePage.dart';
import 'Poz.dart';
import 'PozDetay.dart';
import 'AuthService.dart';

class PozList extends StatefulWidget {
  final List<String> selectedBookCodes;
  final String? SearchQuery;

  const PozList({
    Key? key,
    required this.selectedBookCodes,
    this.SearchQuery,
  }) : super(key: key);

  @override
  State<PozList> createState() => _PozListState();
}

class _PozListState extends State<PozList> {

  final List<Poz> _allPozlar = [];
  List<Poz> _displayPozlar = [];
  List<BookTree> bookstree = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _skip = 0;
  final int _take = 50;

  bool _hasMoreData = true;
  bool canfetch = false;
  bool _isLoading = false;

  String? _token;

  List<dynamic> _filterParam = [
    ["bookCode","contains",""],
    "or",
    ["nodeCode","contains",""],
    "or",
    ["fullCode","contains",""],
    "or",
    ["name","contains",""],
    "or",
    ["unitName","contains",""]
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    if (widget.SearchQuery != null) {
      _searchController.text = widget.SearchQuery!;
    }
    _initTokenAndFirstLoad();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initTokenAndFirstLoad() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final email = dotenv.env['EMAIL'];
    final password = dotenv.env['PASSWORD'];
    final authService = AuthService();
    _token = await authService.signInWithEmailAndPassword(
      email: email ?? "",
      password: password ?? "",
    );

    if (_token != null) {
      _updateFilterParam(_searchController.text);
      await loadbookfromApi();
      await _fetchPozlar();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadbookfromApi() async {
    final url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/workitem/treelist"
          "?Filter=%5B%22parentId%22%2C%22%3D%22%2Cnull%5D"
          "&bookTypeId=1",
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
        final dataList = decoded['data']['data'] as List<dynamic>;
        final fetchedBooks = dataList.map((e) => BookTree.fromJson(e)).toList();
        setState(() {
          bookstree = fetchedBooks;
        });
      }
    } catch (e) {
      print("Hata oluştu (book list): $e");
    }
  }

  void _scrollListener() {
    if (_hasMoreData &&
        canfetch &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.5) {
      _fetchPozlar();
    }
  }

  void _updateFilterParam(String value) {
    _filterParam = [
      ["bookCode","contains",value],
      "or",
      ["nodeCode","contains",value],
      "or",
      ["fullCode","contains",value],
      "or",
      ["name","contains",value],
      "or",
      ["unitName","contains",value]
    ];
  }

  Future<void> _fetchPozlar() async {
    canfetch = false;
    final queryValue = _searchController.text;
    _updateFilterParam(queryValue);

    var selectedNodes = widget.selectedBookCodes.join(',');
    if (selectedNodes.isEmpty) {
      final selectedNodeIds = bookstree.map((b) => b.id!).toList();
      selectedNodes = selectedNodeIds.join(',');
    }
    final nodeIds = selectedNodes.split(',').map(int.parse).toList();
    final filtersMap = {"selectedNodes": nodeIds};
    final encodedAdvancedFilters = Uri.encodeComponent(jsonEncode(filtersMap));
    final encodedFilterJson = Uri.encodeComponent(jsonEncode(_filterParam));

    final url = Uri.parse(
      "https://developer.novusyazilim.com/cns.wa/api/workitem/getworkitems"
          "?Skip=$_skip"
          "&Take=$_take"
          "&Filter=$encodedFilterJson"
          "&advancedFilters=$encodedAdvancedFilters",
    );

    try {
      final response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $_token',
      });
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final dataList = decoded['data']['data'] as List<dynamic>;
        if (dataList.isEmpty) {
          _hasMoreData = false;
        } else {
          final newPozlar = dataList.map((e) => Poz.fromJson(e)).toList();
          setState(() {
            _allPozlar.addAll(newPozlar);
            _displayPozlar = List.from(_allPozlar);
            _skip += _take;
            canfetch = true;
          });
        }
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  void _onSearch() {
    setState(() {
      _allPozlar.clear();
      _displayPozlar.clear();
      _skip = 0;
      _hasMoreData = true;
      canfetch = false;
    });
    _fetchPozlar();
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
            child: Text('Poz Listesi'),
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
          child: Column(
            children: [
              Container(height: 7,width: double.maxFinite,color: Colors.white),
              SizedBox(height: 19),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 300),
              Center(
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
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar:AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('Poz Listesi'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color(0xFFF1F2F6),
      ),
      body: Container(
          color: Color(0xFFFBFBFB),
        child: Column(
            children: [
              Container(height: 7,width: double.maxFinite,color: Colors.white),
              SizedBox(height: 19),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      onPressed: _onSearch,
                      icon: const Icon(Icons.search),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.maxFinite,
                height: 10,
                color: Color(0xFFFEFEFE),
              ),
              Expanded(
                    child: ListView.builder(
                      primary: false,
                      controller: _scrollController,
                      itemCount: _displayPozlar.length,
                      itemBuilder: (context, index) {
                        final pozItem = _displayPozlar[index];
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PozDetail(selectedPoz: pozItem),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Card(
                                color: Color(0xFFFFFFFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                  side: BorderSide.none,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFFFFFFF).withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xFFE3E4E8),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 12,right:12,top: 12,bottom: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(pozItem.bookName ?? '',
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                                          SizedBox(height: 1),
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFBAEDD8),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                              child: Text(pozItem.fullCode ?? '' , style: TextStyle(color: Colors.black),)
                                          ),
                                          SizedBox(height: 1),
                                          Text(pozItem.name ?? '', softWrap: true,style: TextStyle(color: Colors.black.withOpacity(0.8)))
                                          /*Container(
                                            width: double.maxFinite,
                                            height: 2,
                                            color: Color(0xFFEFF2F4),)*/
                                        ],
                                      ),
                                    ),
                                ),
                                ),
                            ),
                          );
                      },
                    ),
                ),
            ],
        ),
      ),
    );
  }
}
