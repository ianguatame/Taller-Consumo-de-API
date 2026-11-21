import 'package:flutter/material.dart';
import 'app_background.dart';
import 'covid_api.dart';
import 'covid_data.dart';
import 'data_card.dart';
import 'notification_service.dart';

const Color accent = Color(0xFF2DD4BF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista de respaldo: se reemplaza cuando la API responde.
  List<String> countries = [
    'Colombia',
    'Mexico',
    'Argentina',
    'Peru',
    'Chile',
    'Spain',
    'USA',
  ];

  String selected = 'Colombia';
  late Future<CovidData> future = fetchCountry(selected);

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  // Ampliación 2: lista de países desde la API.
  Future<void> _loadCountries() async {
    try {
      final list = await fetchCountries();
      if (!mounted || list.isEmpty) return;
      setState(() {
        countries = list;
        if (!countries.contains(selected)) selected = countries.first;
      });
    } catch (_) {
      // Si falla, se mantiene la lista fija de respaldo.
    }
  }

  void _reload() {
    setState(() {
      future = fetchCountry(selected);
    });
  }

  Future<void> _notify(CovidData d) async {
    final n = numberFormat;
    await NotificationService.show(
      title: 'COVID-19: ${d.country}',
      body: 'Casos: ${n.format(d.cases)} | Muertes: ${n.format(d.deaths)} | Hoy: ${n.format(d.todayCases)}',
      bigBody: 'Casos acumulados: ${n.format(d.cases)}\n'
          'Casos del día: ${n.format(d.todayCases)}\n'
          'Muertes acumuladas: ${n.format(d.deaths)}\n'
          'Muertes del día: ${n.format(d.todayDeaths)}\n'
          'Recuperados: ${n.format(d.recovered)}\n'
          'Actualizado: ${dateFormat.format(d.updated)}',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: accent,
        content: Text(
          'Notificación enviada: ${d.country}',
          style: const TextStyle(
            color: Color(0xFF062B33),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.public_rounded, color: accent),
              SizedBox(width: 10),
              Text(
                'Datos COVID-19',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x26FFFFFF)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selected,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF123C4A),
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.expand_more_rounded, color: accent),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    items: countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      selected = value;
                      _reload();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<CovidData>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(color: accent),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded,
                                size: 56, color: deathsColor),
                            const SizedBox(height: 12),
                            Text(
                              'No se pudo consultar: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _reload,
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: const Color(0xFF062B33),
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }
                    final d = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataCard(data: d),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _notify(d),
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: const Color(0xFF062B33),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          icon: const Icon(Icons.notifications_active_rounded),
                          label: const Text('Enviar notificación'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}