import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService {
  final ValueNotifier<List> tableStateNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  List<String> propertyNames = ["name", "style", "ibu"];
  List<String> columnNames = ["Programação", "Assíncrona", "POOI"];
  int selectedIndex = 0;
  int pageSize = 5;

  void carregar(int index) {
    var funcoes = [
      carregarCafes,
      carregarCervejas,
      carregarNacoes,
    ];

    selectedIndex = index;
    funcoes[index]();
  }

  void columnsCervejas() {
    propertyNames = ["name", "style", "ibu"];
    columnNames = ["Nome", "Estilo", "IBU"];
  }

  Future<void> carregarCervejas() async {
    columnsCervejas();
    var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': pageSize.toString()},
    );

    isLoadingNotifier.value = true;

    http.get(beersUri).then((response) {
      var jsonString = response.body;
      var beersJson = jsonDecode(jsonString);

      tableStateNotifier.value = beersJson;

      isLoadingNotifier.value = false;
    }).catchError((error) {
      isLoadingNotifier.value = false;
      print('Erro ao carregar cervejas: $error');
    });
  }

  void columnsCafes() {
    propertyNames = ["blend_name", "origin", "variety"];
    columnNames = ["Nome", "Origem", "Variedades"];
  }

  Future<void> carregarCafes() async {
    columnsCafes();
    var coffeeUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': pageSize.toString()},
    );

    isLoadingNotifier.value = true;

    http.get(coffeeUri).then((response) {
      var jsonString = response.body;
      var coffeesJson = jsonDecode(jsonString);

      tableStateNotifier.value = coffeesJson;

      isLoadingNotifier.value = false;
    }).catchError((error) {
      isLoadingNotifier.value = false;
      print('Erro ao carregar cafés: $error');
    });
  }

  void columnsNacoes() {
    propertyNames = ["nationality", "language", "capital"];
    columnNames = ["Nacionalidade", "Idioma", "Capital"];
  }

  Future<void> carregarNacoes() async {
    columnsNacoes();
    var nationUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': pageSize.toString()},
    );

    isLoadingNotifier.value = true;

    http.get(nationUri).then((response) {
      var jsonString = response.body;
      var nationsJson = jsonDecode(jsonString);

      tableStateNotifier.value = nationsJson;

      isLoadingNotifier.value = false;
    }).catchError((error) {
      isLoadingNotifier.value = false;
      print('Erro ao carregar nações: $error');
    });
  }
}

final dataService = DataService();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Utilizando API receitas 7 e 8"),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(
                      'https://marketplace.canva.com/EADiXvagF_U/1/0/1600w/canva-azul-c%C3%ADrculos-rosa-e-amarelo-boas-vindas-cart%C3%A3o-eFIj9LkquVk.png',
                      height: 200,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bem-vindo ao meu app!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toque em um dos ícones abaixo para carregar os dados.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Quantidade de itens:'),
                    SizedBox(width: 10),
                    DropdownButton<int>(
                      value: dataService.pageSize,
                      items: [
                        DropdownMenuItem<int>(
                          value: 5,
                          child: Text('5'),
                        ),
                        DropdownMenuItem<int>(
                          value: 10,
                          child: Text('10'),
                        ),
                        DropdownMenuItem<int>(
                          value: 15,
                          child: Text('15'),
                        ),
                      ],
                      onChanged: (value) {
                        dataService.pageSize = value!;
                        dataService.carregar(dataService.selectedIndex);
                      },
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: dataService.isLoadingNotifier,
                builder: (_, isLoading, __) {
                  return Visibility(
                    visible: isLoading,
                    child: CircularProgressIndicator(),
                    replacement: DataTableWidget(
                      jsonObjects: dataService.tableStateNotifier.value,
                      columnNames: dataService.columnNames,
                      propertyNames: dataService.propertyNames,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

class NewNavBar extends StatelessWidget {
  final Function(int) itemSelectedCallback;

  NewNavBar({required this.itemSelectedCallback});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              itemSelectedCallback(0);
            },
            icon: Icon(Icons.coffee_outlined),
          ),
          IconButton(
            onPressed: () {
              itemSelectedCallback(1);
            },
            icon: Icon(Icons.local_drink_outlined),
          ),
          IconButton(
            onPressed: () {
              itemSelectedCallback(2);
            },
            icon: Icon(Icons.flag_outlined),
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List? jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget({
    this.jsonObjects,
    this.columnNames = const ["Nome", "Estilo", "IBU"],
    this.propertyNames = const ["name", "style", "ibu"],
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns:
          columnNames.map((name) => DataColumn(label: Text(name))).toList(),
      rows: jsonObjects != null
          ? jsonObjects!.map<DataRow>((jsonObject) {
              return DataRow(
                cells: propertyNames
                    .map((property) => DataCell(Text(jsonObject[property])))
                    .toList(),
              );
            }).toList()
          : [],
    );
  }
}
