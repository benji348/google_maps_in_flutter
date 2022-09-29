import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/advanced/controllers/controllers.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final Completer<GoogleMapController> controller = Completer();
  bool isListChecked = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: getLocations(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final document = snapshot.data['offices'];
            return isListChecked
                ? Column(
                    children: [
                      Flexible(
                        flex: 2,
                        child: theMap(document),
                      ),
                      Flexible(
                        flex: 3,
                        child: ListView.builder(
                          itemCount: document.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () async {
                                  final mapController = await controller.future;
                                  updateCameraWhenSelected(
                                      mapController, document, index);
                                },
                                child: locationListTile(document, index));
                          },
                        ),
                      )
                    ],
                  )
                : Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      theMap(document),
                      Positioned(
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            itemCount: document.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => InkWell(
                              onTap: () async {
                                final mapController = await controller.future;
                                updateCameraWhenSelected(
                                    mapController, document, index);
                              },
                              child: horizontalView(document, index),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: isListChecked
              ? const Icon(Icons.grid_view_sharp)
              : const Icon(Icons.list),
          onPressed: () => setState(() {
            isListChecked = !isListChecked;
          }),
        ),
      ),
    );
  }

  SizedBox horizontalView(document, int index) {
    return SizedBox(
      width: 340,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: ListTile(
              leading: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.network(document[index]['image']),
              ),
              title: Text(document[index]['name'].toString()),
              subtitle: Text(document[index]['address'])),
        ),
      ),
    );
  }

  void updateCameraWhenSelected(
      GoogleMapController mapController, document, int index) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(document[index]['lat'], document[index]['lng']),
            zoom: 16),
      ),
    );
  }

  GoogleMap theMap(document) {
    return GoogleMap(
        onMapCreated: (mapController) => controller.complete(mapController),
        initialCameraPosition:
            const CameraPosition(target: LatLng(0, 0), zoom: 2),
        markers: document
            .map(
              (e) => Marker(
                markerId: MarkerId(e['name']),
                position: LatLng(e['lat'], e['lng']),
                infoWindow: InfoWindow(title: e['name'], snippet: e['address']),
              ),
            )
            .toSet()
            .cast<Marker>());
  }

  ListTile locationListTile(document, int index) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25.0,
        backgroundImage: NetworkImage(document[index]['image']),
      ),
      title: Text(document[index]['name'].toString()),
      subtitle: Text(document[index]['address']),
    );
  }
}
