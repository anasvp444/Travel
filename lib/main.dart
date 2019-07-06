import 'package:flutter/material.dart';
import './custom_shape_clipper.dart';
import './customAppbar.dart';
import './flight_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
      name: 'Travel',
      options: const FirebaseOptions(
          googleAppID: '1:151463788921:android:5946b7104425d2f6',
          apiKey: 'AIzaSyB3ryWfKRX8MykdMQi_Ye5nnlLbrejo6J4',
          databaseURL: 'https://travel-97b63.firebaseio.com/'));

  runApp(MaterialApp(
    title: 'Flight List Mock Up',
    home: HomeScreen(),
    theme: appTheme,
  ));
}

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFEEF772C);

ThemeData appTheme =
    ThemeData(primaryColor: Color(0xFFF3791A), fontFamily: 'Oxygen');

List<String> locations = List();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CustomAppBar(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              HomeScreenTopPart(),
              homeScreenBottompart,
              homeScreenBottompart,
            ],
          ),
        ));
  }
}

TextStyle dropDownLabelStyle = TextStyle(color: Colors.white, fontSize: 16.0);
TextStyle dropDownMenuItemStyle =
    TextStyle(color: Colors.black, fontSize: 16.0);

final _searchFieldController = TextEditingController();

class HomeScreenTopPart extends StatefulWidget {
  @override
  _HomeScreenTopPartState createState() => _HomeScreenTopPartState();
}

class _HomeScreenTopPartState extends State<HomeScreenTopPart> {
  var selectedLocationIndex = 0;
  var isFlightSelected = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 400.0,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [firstColor, secondColor])),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                StreamBuilder(
                    stream:
                        Firestore.instance.collection('locations').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData)
                        addLocations(context, snapshot.data.documents);
                      return !snapshot.hasData
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  PopupMenuButton(
                                      onSelected: (index) {
                                        setState(() {
                                          selectedLocationIndex = index;
                                        });
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            locations[selectedLocationIndex],
                                            style: dropDownLabelStyle,
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                      itemBuilder: (BuildContext context) =>
                                          _buildPopupmenuitem()),
                                  Spacer(),
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            );
                    }),
                SizedBox(
                  height: 50.0,
                ),
                Text(
                  'Where would\nyou want to go?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    child: TextField(
                      controller: _searchFieldController,
                      style: dropDownMenuItemStyle,
                      cursorColor: appTheme.primaryColor,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 14.0),
                          suffixIcon: Material(
                            elevation: 2.0,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            child: InkWell(
                              child: Icon(
                                Icons.search,
                                color: Colors.black,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InheritedFlightListing(
                                              fromLocation: locations[
                                                  selectedLocationIndex],
                                              toLocation:
                                                  _searchFieldController.text,
                                              child: FlightListingScreen(),
                                            )));
                              },
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFlightSelected = true;
                        });
                      },
                      child: ChoiceChip(
                          Icons.flight_takeoff, "Flights", isFlightSelected),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFlightSelected = false;
                        });
                      },
                      child:
                          ChoiceChip(Icons.hotel, "Hotels", !isFlightSelected),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

List<PopupMenuItem<int>> _buildPopupmenuitem() {
  List<PopupMenuItem<int>> popupmenuitem = List();
  for (int i = 0; i < locations.length; i++) {
    popupmenuitem.add(PopupMenuItem(
      child: Text(
        locations[i],
        style: dropDownMenuItemStyle,
      ),
      value: i,
    ));
  }
  return popupmenuitem;
}

addLocations(BuildContext context, List<DocumentSnapshot> snapshots) {
  for (int i = 0; i < snapshots.length; i++) {
    final Location location = Location.fromSnapshot(snapshots[i]);
    locations.add(location.name);
  }
}

class ChoiceChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isSelected;

  ChoiceChip(this.icon, this.text, this.isSelected);

  @override
  _ChoiceChipState createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: widget.isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.all(Radius.circular(20.0)))
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(
              widget.icon,
              size: 20.0,
              color: Colors.white,
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(
              widget.text,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ],
        ));
  }
}

TextStyle viewAllStyle =
    TextStyle(color: appTheme.primaryColor, fontSize: 14.0);

var homeScreenBottompart = Column(
  children: <Widget>[
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Currently Watched Items",
            style: dropDownMenuItemStyle,
          ),
          Spacer(),
          Text(
            "VIEW ALL(12)",
            style: viewAllStyle,
          ),
        ],
      ),
    ),
    Container(
      height: 240.0,
      child: StreamBuilder(
          stream: Firestore.instance.collection('cities').snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildCitiesList(context, snapshot.data.documents);
          }),
    )
  ],
);

Widget _buildCitiesList(
    BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
    itemCount: snapshots.length,
    physics: ClampingScrollPhysics(), //scroll list with body
    shrinkWrap: true,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index) {
      return CityCard(city: City.fromSnapshot(snapshots[index]));
    },
  );
}

class Location {
  final String name;

  Location.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        name = map['name'];

  Location.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

class City {
  final String imagePath, cityName, monthYear, discount;
  final int oldPrice, newPrice;

  City.fromMap(Map<String, dynamic> map)
      : assert(map['imagePath'] != null),
        assert(map['cityName'] != null),
        assert(map['monthYear'] != null),
        assert(map['discount'] != null),
        imagePath = map['imagePath'],
        cityName = map['cityName'],
        monthYear = map['monthYear'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'],
        discount = map['discount'];

  City.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

class CityCard extends StatelessWidget {
  final City city;

  CityCard({this.city});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 210.0,
                      width: 160.0,
                      child: Image.network(
                        city.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      width: 160.0,
                      height: 80.0,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Colors.black,
                              Colors.black.withOpacity(0.01)
                            ])),
                      ),
                    ),
                    Positioned(
                      left: 10.0,
                      bottom: 10.0,
                      right: 5.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                city.cityName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18.0),
                              ),
                              Text(
                                city.monthYear,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                    fontSize: 14.0),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            child: Text(
                              "${city.discount}%",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                          )
                        ],
                      ),
                    )
                  ],
                )),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  '\$${city.newPrice}',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  '\$${city.oldPrice}',
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0,
                      decoration: TextDecoration.lineThrough),
                )
              ],
            )
          ],
        ));
  }
}
