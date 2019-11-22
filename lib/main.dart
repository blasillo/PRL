import 'package:flutter/material.dart';
import 'package:notas_app/ui/note_list.dart';

void main() {
	runApp(MyApp());
}


class MyApp extends StatelessWidget {

	@override
  Widget build(BuildContext context) {

    return MaterialApp(
	    title: 'SDD Va PRL',
	    debugShowCheckedModeBanner: false,
	    theme: ThemeData(
		    primarySwatch: Colors.yellow
	    ),
	    home: NoteList(),
    );
  }
}