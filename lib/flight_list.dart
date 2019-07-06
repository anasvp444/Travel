import 'package:flutter/material.dart';
import './custom_shape_clipper.dart';
import './main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Color discountbackgroundColor = Color(0xEEFFD633);
final Color flightBorderColor = Color(0xFFE6E6E6);
final Color chipbackgroundColor = Color(0xFFF6F6F6);

class InheritedFlightListing extends InheritedWidget {
  final String fromLocation, toLocation;
  InheritedFlightListing({this.fromLocation, this.toLocation, Widget child})
      : super(child: child);
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedFlightListing of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedFlightListing);
}

class FlightListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Search Result"),
          elevation: 0.0,
          centerTitle: true,
          leading: InkWell(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              FlightListTopPart(),
              SizedBox(
                height: 20.0,
              ),
              FlightBottomPart()
            ],
          ),
        ));
  }
}

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFEEF772C);

class FlightListTopPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: 160.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [firstColor, secondColor])),
            )),
        Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              elevation: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            InheritedFlightListing.of(context).fromLocation,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.normal),
                          ),
                          Divider(
                            color: Colors.grey,
                            height: 20.0,
                          ),
                          Text(
                            InheritedFlightListing.of(context).toLocation,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.import_export,
                      color: Colors.black,
                      size: 32.0,
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class FlightBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Column(
        children: <Widget>[
          Text(
            "Best deals for next 6 month",
            style: TextStyle(color: Colors.black, fontSize: 16.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          StreamBuilder(
              stream: Firestore.instance.collection('deals').snapshots(),
              builder: (context, snapshot) {
                return !snapshot.hasData
                    ? Center(child:  CircularProgressIndicator(),)
                    : _buildDealsList(context, snapshot.data.documents);
              })
        ],
      ),
    );
  }
}

Widget _buildDealsList(BuildContext context, List<DocumentSnapshot> snapshots) {

  return ListView.builder(
    itemCount: snapshots.length,
    physics: ClampingScrollPhysics(), //scroll list with body
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemBuilder: (context, index) {
      return FlightCard(
          
          flightDetails: FlightDetails.fromSnapshot(snapshots[index]));
    },
  );
}

class FlightDetails {
  final String airlines, date, discount, rating;
  final int oldPrice, newPrice;

  FlightDetails.fromMap(Map<String, dynamic> map)
      : assert(map['airlines'] != null),
        assert(map['date'] != null),
        assert(map['discount'] != null),
        assert(map['rating'] != null),
        airlines = map['airlines'],
        date = map['date'],
        discount = map['discount'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'],
        rating = map['rating'];

  FlightDetails.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

class FlightCard extends StatelessWidget {
  final FlightDetails flightDetails;

  FlightCard({this.flightDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
                border: Border.all(color: flightBorderColor),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        "\$${flightDetails.newPrice}",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        "(\$${flightDetails.oldPrice})",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 4.0,
                    children: <Widget>[
                      FlightDetailChip(
                          Icons.calendar_today, "${flightDetails.date}"),
                      FlightDetailChip(
                          Icons.flight_takeoff, "${flightDetails.airlines}"),
                      FlightDetailChip(Icons.star, "${flightDetails.rating}"),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 10.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "${flightDetails.discount}%",
                style: TextStyle(
                    color: appTheme.primaryColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                  color: discountbackgroundColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      topLeft: Radius.circular(10.0))),
            ),
          )
        ],
      ),
    );
  }
}

class FlightDetailChip extends StatelessWidget {
  final IconData iconData;
  final String label;
  FlightDetailChip(this.iconData, this.label);
  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.black, fontSize: 14.0),
      backgroundColor: chipbackgroundColor,
      avatar: Icon(
        iconData,
        size: 16.0,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );
  }
}
