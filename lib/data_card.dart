import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'covid_data.dart';

final NumberFormat numberFormat = NumberFormat.decimalPattern('es_CO');
final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

// Colores de cada dato: cada cifra tiene su propio color.
const Color casesColor = Color(0xFF5EB1FF);
const Color todayCasesColor = Color(0xFFFFC857);
const Color deathsColor = Color(0xFFFF6B6B);
const Color todayDeathsColor = Color(0xFFFF9F68);
const Color recoveredColor = Color(0xFF4ADE9C);

class DataCard extends StatelessWidget {
  final CovidData data;

  const DataCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(data: data),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Casos acumulados',
                value: numberFormat.format(data.cases),
                icon: Icons.coronavirus_rounded,
                color: casesColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Casos del día',
                value: numberFormat.format(data.todayCases),
                icon: Icons.trending_up_rounded,
                color: todayCasesColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Muertes acumuladas',
                value: numberFormat.format(data.deaths),
                icon: Icons.heart_broken_rounded,
                color: deathsColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Muertes del día',
                value: numberFormat.format(data.todayDeaths),
                icon: Icons.schedule_rounded,
                color: todayDeathsColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatTile(
          label: 'Recuperados',
          value: numberFormat.format(data.recovered),
          icon: Icons.favorite_rounded,
          color: recoveredColor,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final CovidData data;

  const _Header({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x26FFFFFF)),
      ),
      child: Row(
        children: [
          // Bandera del país (ampliación 1).
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: data.flag != null
                  ? Image.network(
                      data.flag!,
                      width: 76,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                        width: 76,
                        height: 52,
                        child: Icon(Icons.flag_rounded, size: 32),
                      ),
                    )
                  : const SizedBox(
                      width: 76,
                      height: 52,
                      child: Icon(Icons.flag_rounded, size: 32),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.country,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Actualizado: ${dateFormat.format(data.updated)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ampliación 5: tarjeta de dato reutilizable, con una barra de color
// al lado izquierdo que identifica el tipo de dato.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0x14FFFFFF),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 18, color: color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xB3FFFFFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}