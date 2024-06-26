import 'package:dengue_dashboard/core/data_persist_service.dart';
import 'package:dengue_dashboard/modules/constants/region_const.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/charts.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/datepicker.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/drop_menu_age.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/drop_menu_region.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/drop_menu_state.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/drop_menu_town.dart';
import 'package:dengue_dashboard/modules/home_module/widgets/gender_radio.dart';
import 'package:estados_municipios/estados_municipios.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRegiao = false;
  bool isState = false;
  List<String> states = [];
  List<String> towns = [];
  bool isLoading = true;
  ValueNotifier<bool> selected = ValueNotifier(false);
  String dropdownValue = '';
  String dropdownValueTown = '';

  Future<List<String>> getState() async {
    final controller = EstadosMunicipiosController();
    final estados = await controller.buscaTodosEstados();
    var regiao = await readData('regiao', 3);
    setState(() {
      states = [];
    });

    for (int i = 0; i < estados.length; i++) {
      print(estados[i].regiao.nome);
      if (estados[i].regiao.nome == regiao) {
        states.add(estados[i].sigla);
      } else if (regiao == null) {
        states.add(estados[i].sigla);
      }
    }

    setState(() {
      isLoading = false;
      dropdownValue = states.first;
    });
    setState(() {
      dropdownValue = states.first;
    });
    return [];
  }

  Future<List<String>> getTown(String sigla) async {
    final controller = EstadosMunicipiosController();
    final municipios = await controller.buscaMunicipiosPorEstado(sigla);
    print(municipios);
    setState(() {
      towns = [];
    });
    for (int i = 0; i < municipios.length; i++) {
      print(municipios[i].nome);
      towns.add(municipios[i].nome);
    }
    await Future.delayed(
      const Duration(seconds: 2),
    );
    setState(() {
      isLoading = false;
      dropdownValueTown = towns.first;
      isState = true;
    });
    return [];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Forecasting da dengue no Brasil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Opacity(
              opacity: 0.5,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Card(
                    color: Colors.cyan[200],
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: 80,
                      child: Row(
                        children: [
                          Spacer(),
                          const Center(
                            child: RadioGender(),
                          ),
                          DropdownMenu<String>(
                            label: const Text('Região'),
                            initialSelection: listRegion.first,
                            onSelected: (String? value) async {
                              setState(() {
                                dropdownValue = value!;
                                isLoading = true;
                              });
                              await getState();
                              await Future.delayed(
                                const Duration(seconds: 2),
                              );
                              setState(() {
                                dropdownValue = value!;
                              });
                              await insertData(3, 'regiao', value);
                            },
                            dropdownMenuEntries: listRegion
                                .map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                  value: value, label: value);
                            }).toList(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          DropdownMenu<String>(
                            label: const Text('Estado'),
                            initialSelection: states.first,
                            onSelected: (String? value) async {
                              setState(() {
                                dropdownValue = value!;
                                isLoading = true;
                              });
                              //await getTown(dropdownValue);
                              // await Future.delayed(
                              //const Duration(seconds: 2),
                              //);
                              setState(() {
                                dropdownValue = value!;
                              });
                              await insertData(3, 'estado', value);
                            },
                            dropdownMenuEntries: states
                                .map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                  value: value, label: value);
                            }).toList(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          /* isState
                              ? DropdownMenuTown(list: towns)
                              : const SizedBox(
                                  width: 0,
                                ),
                          isState
                              ? const SizedBox(
                                  width: 10,
                                )
                              : const SizedBox(
                                  width: 0,
                                ),
                          const SizedBox(
                            width: 120,
                            height: 50,
                            child: DatePickerFilter(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),*/
                          const DropdownMenuAge(),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ChartScreen(),
                ),
              ],
            ),
    );
  }
}
