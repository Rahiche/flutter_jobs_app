
import 'package:flutter/material.dart';
import 'package:flutter_jobs/DetailScreen.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    Key key,
  }) : super(key: key);

  @override
  CustomDrawerState createState() {
    return CustomDrawerState();
  }
}

class CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        ClipPath(
          clipper: CustomDrawerClipper(),
          child: Material(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(100.0),
                bottomRight: Radius.circular(100.0)),
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 70,
                  color: Color.fromRGBO(47, 65, 123, 1.0),
                  child: Column(
                    children: <Widget>[
                      JobsAppTitle(),
                      SizedBox(height: 50.0),
                      Divider(color: Colors.transparent),
                      buildCard("Job Title", Icons.list, () {
                        Navigator.pop(context);
                      }),
                      Divider(color: Colors.transparent),
                      buildCard("Add new", Icons.add, () {
                        launchURL(
                            "https://docs.google.com/forms/d/e/1FAIpQLSez_Gw1VJzcl6t5FRGT6WpIybC_7QQs1-bnAufiCemMeQB1vw/viewform");
                      }),
                      Divider(color: Colors.transparent),
                      buildCard("Mailing list", Icons.mail, () {
                        launchURL(
                            "https://cogitas.us6.list-manage.com/subscribe/post?u=64ec8fbc3fe206f70c0250aa9&id=8cce74d650");
                      }),
                      Divider(color: Colors.transparent),
                      Expanded(child: Container()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 20.0),
                          Image.asset(
                            "assets/twitter.png",
                            width: 50.0,
                            height: 50.0,
                          ),
                          Text(
                            "@flutter_jobs",
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 20.0),
                          Image.asset(
                            "assets/website.png",
                            width: 50.0,
                            height: 50.0,
                          ),
                          Text(
                            "flutterjobs.info",
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        FractionalTranslation(
          translation: Offset(-0.07, 0.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Material(
                elevation: 5.0,
                type: MaterialType.circle,
                color: Colors.redAccent,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 80.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  buildCard(String title, IconData icon, Function callback) {
    return FlatButton(
      onPressed: callback,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 10.0),
          Icon(
            icon,
            color: Colors.white,
            size: 40.0,
          ),
          SizedBox(width: 50.0),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ],
      ),
    );
  }
}

class CustomDrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height / 2 - 45);
//    path.conicTo(size.width - 70, size.height / 2, size.width,
//        size.height / 2 + 70, 1.0);
    print(size.width);
    path.arcToPoint(
      Offset(size.width, size.height / 2 + 45),
      radius: Radius.circular(45.0),
      clockwise: false,
    );
//    path.addRect(Rect.fromLTWH(100.0, 10.0, 100.0, 100.0));
//    path.arcTo(Rect.fromLTWH(size.width - 70, size.height / 2, 70.0, 70.0), pi,
//        pi / 2, false);
    path.lineTo(size.width, size.height / 2 + 70.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class JobsAppTitle extends StatelessWidget {
  const JobsAppTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlutterLogo(
                  size: 35.0,
                ),
                Text(
                  "JOBS",
                  style: TextStyle(
                      fontSize: 35.0,
                      fontFamily: 'Cabin Sketch',
                      color: Colors.white),
                ),
              ],
            ),
            Container(),
          ],
        ),
      ),
    );
  }
}
