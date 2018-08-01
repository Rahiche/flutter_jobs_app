import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_jobs/Company.dart';
import 'package:flutter_jobs/CustomDrawer.dart';
import 'package:flutter_jobs/DetailScreen.dart';
import 'package:flutter_jobs/Job.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class JobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<Job> jobsList = [];

  //extract the link from the inner HTML
  getLink(String html) {
    if (html.length > 10) {
      String link = html.substring(9);
      var i = link.indexOf('" target="');
      link = link.replaceRange(i, link.length, "");
      return link;
    } else
      return "NoURL";
  }

  Future<List<String>> getData() async {
    //initialize a new list
    List<String> myList = [];

    //connect to flutter jobs web site
    http.Response response = await http.get('https://flutterjobs.info/');

    //parse and extract the data from the web site
    dom.Document document = parser.parse(response.body);
    document.getElementsByTagName('tr').forEach((child) {
      jobsList.add(Job(
        title: child.getElementsByTagName('th').first.text,
        dateAdded: child.getElementsByTagName('th').last.text,
        location: child.getElementsByTagName('th')[2].text,
        company: child.getElementsByTagName('th')[1].text,
        url: getLink(child.getElementsByTagName("th").first.innerHtml.trim()),
      ));
    });
    // remove the first item which is the title item in the table
    jobsList.removeAt(0);

    print("data loaded");
    //just to wait until the get request completed
    return myList;
  }

  showAbout() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("About Flutter Jobs"),
          children: <Widget>[
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                    text: 'This App is just an client of'),
                TextSpan(
                    style: TextStyle(color: Colors.blue, fontSize: 20.0),
                    text: ' flutterjobs.info '),
                TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                    text: "which is a is a job board for Flutter jobs "),
                TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                    text: "the app created by raouf rahiche ")
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            )
          ],
          contentPadding:
              EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0, bottom: 5.0),
        );
      },
    );
  }

  buildItem(Job item) {
    return ClipPath(
      clipper: Clipper(),
      child: Card(
          color: Color.fromRGBO(47, 65, 123, 1.0),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
//                                      side: BorderSide(color: Colors.white70,width: 2.0),
              borderRadius: BorderRadius.circular(25.0)),
          child: InkWell(
            onTap: () {
              print(item.company.trim());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detail(item),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 30.0, top: 20.0, right: 10.0, bottom: 20.0),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                            height: 50.0,
                            child: Text(
                              item.title.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.date_range,
                        color: Colors.white70,
                      ),
                      Text(
                        item.dateAdded.trim(),
                        style: TextStyle(color: Colors.white70),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                        item.location.trim(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.location_city,
                        color: Colors.white,
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  buildListView() {
    return ListView(
        children: jobsList.isNotEmpty
            ? jobsList.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Stack(
                    children: <Widget>[
                      Dismissible(
                        key: Key(item.company),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            jobsList.removeAt(jobsList.indexOf(item));
                          });
                        },
                        child: buildItem(item),
                      ),
                      new CircleCompanyLogo(
                        company: item.company,
                      ),
                    ],
                  ),
                );
              }).toList()
            : []);
  }

  bool loading = true;

  @override
  void initState() {
    super.initState();
    getData().then((d) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(37, 52, 104, 1.0),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.info),
                color: Colors.white,
                onPressed: showAbout)
          ],
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: JobsAppTitle(),
        ),
        drawer: CustomDrawer(),
        body: !loading
            ? RefreshIndicator(
                onRefresh: () async {
                  jobsList.clear();
                  await getData();
                  setState(() {});
                },
                child: buildListView(),
              )
            : Center(
                child: CircularProgressIndicator(
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
      ),
    );
  }
}

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    var radius = 28.0;

    path.lineTo(0.0, size.height / 2 + radius);
    path.arcToPoint(
      Offset(0.0, size.height / 2 - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CircleCompanyLogo extends StatefulWidget {
  final String company;

  const CircleCompanyLogo({
    this.company,
    Key key,
  }) : super(key: key);

  @override
  CircleCompanyLogoState createState() {
    return new CircleCompanyLogoState();
  }
}

class CircleCompanyLogoState extends State<CircleCompanyLogo> {
  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      child: Material(
        type: MaterialType.circle,
        color: Colors.white,
        elevation: 10.0,
        child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(width: 1.0, color: Colors.transparent)),
            height: 50.0,
            width: 50.0,
            child: FutureBuilder<Company>(
              future: getDomain(widget.company.trim()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data.logo),
                  );
                } else {
                  return new Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Color.fromRGBO(37, 52, 104, 1.0)),
                    ),
                  );
                }
              },
            )),
      ),
      translation: Offset(-0.5, 0.82),
    );
  }
}
