import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yala_pay/providers/repo_provider.dart';
import 'package:yala_pay/repositories/localDB/country_city_repo.dart';

class CountryCityNotifier extends AsyncNotifier<List<String>> {
  CountryCityRepo? _repo;

  @override
  Future<List<String>> build() async {
    _repo = await ref.watch(countryCityRepoProvider.future);
    print("Fetching countries...");
    await _repo?.initializeData();
    final countries = await _repo?.getCountries();
    print("Fetched countries: count: ${countries?.length}");
    return countries ?? [];
  }

  Future<List<String>> getCitiesForCountry(String countryName) async {
    return await _repo!.getCitiesInCountry(countryName);
  }

}

final countryCityNotifierProvider =
    AsyncNotifierProvider<CountryCityNotifier, List<String>>(
        () => CountryCityNotifier());
