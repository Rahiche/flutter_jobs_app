import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_jobs/CompanyCircle.dart';
import 'package:flutter_jobs/CustomDrawer.dart';
import 'package:flutter_jobs/DetailScreen.dart';
import 'package:flutter_jobs/Job.dart';
import 'package:flutter_jobs/utils/Colors.dart';
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

  buildListView() {
//    return JobListView();
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
    return Scaffold(
      backgroundColor: MyColors.bkColor,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info), color: Colors.white, onPressed: showAbout)
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
              child: JobListView(list: jobsList),
            )
          : Center(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
    );
  }
}

class JobListView extends StatefulWidget {
  const JobListView({
    Key key,
    this.list,
  }) : super(key: key);
  final List<Job> list;

  @override
  JobListViewState createState() {
    return new JobListViewState();
  }
}

class JobListViewState extends State<JobListView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: widget.list.isNotEmpty
            ? widget.list.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Stack(
                    children: <Widget>[
                      Dismissible(
                        key: Key(item.company),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          setState(() {
                            widget.list.removeAt(widget.list.indexOf(item));
                          });
                        },
                        child: ClippedItem(item: item),
                      ),
                      CircleCompanyLogo(
                        company: item.company,
                      ),
                    ],
                  ),
                );
              }).toList()
            : []);
  }
}

class ClippedItem extends StatefulWidget {
  const ClippedItem({
    Key key,
    this.item,
  }) : super(key: key);

  final Job item;

  @override
  ClippedItemState createState() {
    return ClippedItemState();
  }
}

class ClippedItemState extends State<ClippedItem>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    final CurvedAnimation curvedAnimation = CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn);
    animation = Tween<Offset>(begin: Offset(200.0, 0.0), end: Offset(0.0, 0.0))
        .animate(curvedAnimation);

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation,
      child: ClipPath(
        clipper: Clipper(),
        child: Card(
          color: Color.fromRGBO(47, 65, 123, 1.0),
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: InkWell(
            onTap: () {
              print(widget.item.company.trim());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detail(widget.item),
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
                              widget.item.title.trim(),
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
                        widget.item.dateAdded.trim(),
                        style: TextStyle(color: Colors.white70),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Text(
                        widget.item.location.trim(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.location_city,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
