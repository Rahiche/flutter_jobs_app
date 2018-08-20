import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_jobs/utils/Colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_jobs/Job.dart';
import 'package:flutter_jobs/Company.dart';
import 'package:http/http.dart' as http;

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Company> getDomain(String name) async {
  final response = await http.get(
    'https://company.clearbit.com/v1/domains/find?name=$name',
    headers: {
      HttpHeaders.AUTHORIZATION: "Bearer sk_fca4ae30e175bae925b6eb37d567740c",
    },
  );
  final responseJson = json.decode(response.body);

  if (response.statusCode == 200) {
    return Company.fromJson(responseJson);
  } else if (response.statusCode == 404 || response.statusCode == 422) {
    return Company(
        name: "Flutter",
        logo: "https://logo.clearbit.com/flutter.io",
        domain: "flutter.io");
  }
  return Company(
      name: "Flutter",
      logo: "https://logo.clearbit.com/flutter.io",
      domain: "flutter.io");
}

class Detail extends StatefulWidget {
  final Job job;

  Detail(this.job);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  buildLogo() {
    return FutureBuilder<Company>(
      future: getDomain(widget.job.company.trim()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Material(
              type: MaterialType.card,
              elevation: 8.0,
              child: Image.network(snapshot.data.logo));
        } else {
          return Center();
        }
      },
    );
  }

  buildTitle() {
    return FutureBuilder<Company>(
      future: getDomain(widget.job.company.trim()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      snapshot.data.name,
                      style: TextStyle(fontSize: 40.0, color: Colors.white),
                    ),
                  ),
                ),
                Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      snapshot.data.domain,
                      style: TextStyle(
                          fontSize: 20.0, color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Text("");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          color: MyColors.bkColor,
          child: Stack(
            children: <Widget>[
              Material(
                elevation: 10.0,
                color: Color.fromRGBO(47, 65, 123, 1.0),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100.0),
                    bottomRight: Radius.circular(100.0)),
                child: Container(
                  height: 200.0,
                ),
              ),
              Container(
                height: 300.0,
                child: FractionalTranslation(
                  translation: Offset(0.0, 0.45),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: buildLogo(),
                  ),
                ),
              ),
              buildTitle(),
              Padding(
                padding: const EdgeInsets.only(top: 300.0),
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            "${widget.job.title.trim()}",
                            style:
                                TextStyle(fontSize: 25.0, color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: RaisedButton(
                          color: Colors.blueAccent,
                          child: Text(
                            "Apply",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            launchURL(widget.job.url);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.date_range,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "${widget.job.dateAdded.trim()}",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),

                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.place,
                                    size: 40.0,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "${widget.job.location.trim()}",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
