import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_in_flutter/constant/constant.dart';
import 'package:http/http.dart' as http;

getLocations() async {
  try {
    final response = await http.get(Uri.parse(googleLocationsURL));
    if (response.statusCode == 200) {
      jsonDecode(response.body) as Map<String, dynamic>;
    }
  } catch (err) {
    debugPrint(err.toString());
  }

  //when the above request fails we can load googleLocations localy
  return jsonDecode(await rootBundle.loadString('assets/locations.json'));
}
