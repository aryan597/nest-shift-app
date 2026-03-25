import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/dummy_data_service.dart';

final energyChartProvider = FutureProvider<List<FlSpot>>((ref) async {
  final dummyService = ref.read(dummyDataServiceProvider);
  await Future.delayed(const Duration(milliseconds: 400));
  return dummyService.getDummyEnergyData();
});
