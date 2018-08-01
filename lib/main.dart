
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_jobs/JoblistScreen.dart';


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Jobs",
      initialRoute: '/',
      routes: {
        '/': (context) => JobListScreen(),
      },
    ),
  );
}



