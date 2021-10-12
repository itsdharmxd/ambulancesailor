import 'dart:ffi';
import 'dart:typed_data';
import 'package:ambulancesailor/components/config.dart' as config;
import 'package:ambulancesailor/components/models/Broadcast.dart';
import 'package:ambulancesailor/components/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_api/core/utills/place_status.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as L;
import 'package:flutter_google_places_api/flutter_google_places_api.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as pp;
import 'package:provider/provider.dart';
import 'package:flutter/src/material/stepper.dart ' as S;
import 'package:geocoding/geocoding.dart' as g;
import 'package:ambulancesailor/components/Routes/ANC.dart' as ANC;

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  late LatLng currentlatlog, destination;

  String destinationName = "None", currentName = 'None';

  late GoogleMapController _controller;

  late Uint8List imageData;

  L.Location _locationTracker = L.Location();

  dynamic _locationSubscription;

  Set<Marker> setmarket = {};

  Set<Circle> setcircle = {};

  Set<Polyline> setpolyline = {};

  bool switchstate = false;

  double currentzoom = 17;

  List<bool> visible = [false, false, false, false];

  Broadcast _broadcast = Broadcast();

  NearbySearchResponse response = NearbySearchResponse(
      status: PlaceStatus(status: "null"), results: [], htmlAttributions: []);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DirectionsService.init(config.mykey);
    _locationSubscription = null;
    currentlatlog = LatLng(22.5958, 88.2636);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Consumer<UserProvider>(
        builder: (context, user, _) => Scaffold(
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.ambulanceno,
                      style: TextStyle(fontSize: 50),
                      textAlign: TextAlign.start,
                    ),
                  ],
                )),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(user.drivername),
                ),
                ListTile(
                  leading: Icon(Icons.location_searching),
                  title: Text('current :\n ${currentName}' ),
                ),
                ListTile(
                  leading: Icon(Icons.location_on_sharp),
                  title: Text('Selected Hospital :\n ${destinationName}'),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Checks',
                  ),
                ),
                 ListTile(
                  leading: (visible[3])?  Icon(Icons.check_circle, color: Colors.green) : Icon(Icons.wrong_location ,color:Colors.red),
                  title: Text('Broadcast'),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: Text("Ambulance Sailor"),
            actions: [
              Switch(
                value: switchstate,
                onChanged: switchOnChange,
                activeColor: Colors.red,
              )
            ],
          ),
          body: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  zoomControlsEnabled: false,
                  onTap: (latlng) {
                    print(latlng.toJson());
                  },
                  polylines: setpolyline,
                  onCameraMove: (cameraposition) {
                    currentzoom = cameraposition.zoom;
                    // print(currentzoom);
                  },
                  mapToolbarEnabled: true,
                  trafficEnabled: false,
                  circles: setcircle,
                  markers: setmarket,
                  compassEnabled: true,
                  initialCameraPosition:
                      CameraPosition(target: currentlatlog, zoom: 0.0),
                  mapType: MapType.hybrid,
                  onMapCreated: (controler) {
                    _controller = controler;
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * (0.05),
                right: MediaQuery.of(context).size.width * (0.05),
                child: Container(
                  width: MediaQuery.of(context).size.width * (0.15),
                  height: MediaQuery.of(context).size.height * (0.5),
                  child: Column(
                    children: [
                      (!visible[0])
                          ? SizedBox()
                          : FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.teal,
                              tooltip: "Near By Hospitals",
                              onPressed: nearByHospital,
                              child: Icon(Icons.local_hospital),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (!visible[1])
                          ? SizedBox()
                          : FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.teal,
                              tooltip: "get lane",
                              onPressed: getlane,
                              child: Icon(Icons.forward),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      (!visible[2])
                          ? SizedBox()
                          : FloatingActionButton(
                              heroTag: null,
                              tooltip: "broadcast",
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.router),
                              onPressed: broadcasttopath),
                      SizedBox(
                        height: 10,
                      ),
                      (!visible[3])
                          ? SizedBox()
                          : FloatingActionButton(
                              heroTag: null,
                              tooltip: "Restore",
                              backgroundColor: Colors.teal,
                              onPressed: cancelall,
                              child: Icon(Icons.restore_rounded),
                            )
                    ],
                  ),
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.teal,
            tooltip: "Current Location",
            onPressed: () {
              getCurrentlocation();
            },
            child: Icon(Icons.location_searching_rounded),
          ),
        ),
      ),
    );
  }

//--------------------------------------------------------------------------------------------------------------

// all functions

  broadcasttopath() async {
    // List<g.Placemark> lp = await g.placemarkFromCoordinates(
    //     currentlatlog.latitude, currentlatlog.longitude);
    _broadcast.from = currentName;

    _broadcast.ambulaceno = context.read<UserProvider>().ambulanceno;

    _broadcast.mobileno = context.read<UserProvider>().mobileno;

    _broadcast.to = destinationName;
    setState(() {
      visible[3] = true;
    });
    ANC.broadcasttoambulance(_broadcast);
  }

  cancelall() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }

    setmarket = {};
    setpolyline = {};
    setcircle = {};
    _broadcast = Broadcast();
    setState(() {
      visible[0] = visible[1] = visible[2] = visible[3] = false;
    });
  }

  getlane() {
    DirectionsService directionsService = DirectionsService();

    DirectionsRequest request = DirectionsRequest(
      origin: '${this.currentlatlog.latitude},${this.currentlatlog.longitude}',
      destination: '${this.destination.latitude},${this.destination.longitude}',
      travelMode: TravelMode.driving,
    );

    directionsService.route(request,
        (DirectionsResult response, DirectionsStatus status) {
      if (status == DirectionsStatus.ok) {
        response.routes.forEach((element) {
          pp.PolylinePoints polylinePoints = pp.PolylinePoints();
          List<pp.PointLatLng> result =
              polylinePoints.decodePolyline(element.overviewPolyline.points);

          List<LatLng> points = [];
          _broadcast.coordinates = [];
          result.forEach((element) {
            Coordinate c = Coordinate(
                latitude: element.latitude, longitude: element.longitude);
            _broadcast.coordinates!.add(c);
            points.add(LatLng(element.latitude, element.longitude));
          });

          List<double> distances = [];

          double speed =
              element.legs[0].distance.value / element.legs[0].duration.value;

          distances.add(0);
          _broadcast.coordinates![0].duration = distances[0] / speed;
          double distancetillnow = 0;
          for (int i = 1; i < points.length; i++) {
            distancetillnow += Geolocator.distanceBetween(
                points[i - 1].latitude,
                points[i - 1].longitude,
                points[i].latitude,
                points[i].longitude);

            distances.add(distancetillnow);
            _broadcast.coordinates![i].duration = distances[i] / speed;
          }

          Polyline polyline = Polyline(
              width: 5,
              color: Colors.blue,
              polylineId: PolylineId("current"),
              points: points);

          setpolyline.add(polyline);

          // int currindex = 0;
          // polyline.points.forEach((element) {
          //   setmarket.add(Marker(
          //     anchor: Offset(0.5, 0.5),
          //     infoWindow: InfoWindow(title: distances[currindex].toString()),
          //     markerId: MarkerId(element.hashCode.toString()),
          //     position: LatLng(element.latitude, element.longitude),
          //     icon: BitmapDescriptor.defaultMarkerWithHue(
          //         BitmapDescriptor.hueRed),
          //     zIndex: 2,
          //   ));
          //   currindex++;
          // });
        });
        setState(() {
          visible[2] = true;
        });
      } else {
        print("fail");
      }
    });
  }

  void nearByHospital() async {
    print("called");

    if (this.response.results.length != 0) {}

    response = await NearbySearchRequest(
            keyword: 'Hospital',
            key: config.mykey,
            location: Location(
                lat: currentlatlog.latitude, lng: currentlatlog.longitude),
            radius: 5000)
        .call();

    if (response == null) {
      return;
    }

    response.results.forEach((element) {
      setmarket.add(Marker(
          onTap: () {
            LatLng position = LatLng(
                element.geometry.location.lat, element.geometry.location.lng);
            destination = position;
            destinationName = element.name;
          },
          infoWindow: InfoWindow(title: element.name),
          position: LatLng(
              element.geometry.location.lat, element.geometry.location.lng),
          markerId: MarkerId(element.name),
          flat: true,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)));
    });
    List<g.Placemark> lp = await g.placemarkFromCoordinates(
        currentlatlog.latitude, currentlatlog.longitude);
    currentName = '${lp[0].street} ${lp[0].subLocality} ${lp[0].locality}';
    setState(() {
      visible[1] = true;
    });

    _controller.animateCamera(CameraUpdate.zoomTo(14.0));
  }

  switchOnChange(bool state) {
    if (state) {
      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (_controller != null) {
          this.setState(() {
            currentlatlog =
                LatLng(newLocalData.latitude!, newLocalData.longitude!);
            // marker
            setmarket.add(Marker(
                infoWindow: InfoWindow(title: "My location"),
                position: currentlatlog,
                markerId: MarkerId("current"),
                flat: true,
                zIndex: 2,
                anchor: Offset(0.5, 0.5),
                icon: BitmapDescriptor.fromBytes(imageData)));
            // circle
            setcircle.add(Circle(
              radius: newLocalData.accuracy!,
              circleId: CircleId("current"),
              center: currentlatlog,
              zIndex: 1,
              strokeColor: Colors.transparent,
              fillColor: Colors.lightBlueAccent.withAlpha(70),
            ));

            _controller
                .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
              target: currentlatlog,
              zoom: currentzoom,
              tilt: 0,
              //bearing: 192.83
            )));
          });
        }
      });
    } else {
      if (_locationSubscription != null) _locationSubscription.cancel();
    }

    setState(() {
      switchstate = !switchstate;
    });
  }

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("images/locationicon.png");
    return byteData.buffer.asUint8List();
  }

  void getCurrentlocation() async {
    try {
      imageData = await getMarker();
      var location = await _locationTracker.getLocation();
      currentlatlog = LatLng(location.latitude!, location.longitude!);

      // marker
      setmarket.add(Marker(
          infoWindow: InfoWindow(title: "My location"),
          position: currentlatlog,
          markerId: MarkerId("current"),
          flat: true,
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData)));
      // circle
      setcircle.add(Circle(
        radius: 50,
        circleId: CircleId("current"),
        center: currentlatlog,
        zIndex: 1,
        strokeColor: Colors.transparent,
        fillColor: Colors.lightBlueAccent.withAlpha(70),
      ));
      setState(() {
        visible[0] = true;

        _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: currentlatlog,
          zoom: 17,
          tilt: 0,
          //bearing: 192.83
        )));
      });
    } on PlatformException catch (d) {
      print(d.message);
    }
  }
}
