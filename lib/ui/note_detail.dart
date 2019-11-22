import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:notas_app/database/database_helper.dart';
import 'package:notas_app/models/note.dart';

class NoteDetail extends StatefulWidget {

	final String appBarTitle;
	final Note note;

	NoteDetail(this. note, this.appBarTitle);

	@override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}



class NoteDetailState extends State<NoteDetail> {

	static var _priorities = ['Alto', 'Bajo'];
	DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
	Note note;

	TextEditingController titleController = TextEditingController();
	TextEditingController descriptionController = TextEditingController();

	NoteDetailState(this.note, this.appBarTitle);


  @override
  Widget build(BuildContext context) {

		TextStyle textStyle = Theme.of(context).textTheme.title;

		titleController.text = note.title;
		descriptionController.text = '';
    return WillPopScope(
	    onWillPop: ()
       {
		    moveToLastScreen();
	    },

	    child: Scaffold(
        backgroundColor: Colors.yellowAccent,
	      appBar: AppBar(
		      title: Text(appBarTitle),
          backgroundColor: Colors.yellow,
		      leading: IconButton(icon: Icon(Icons.arrow_back),
				    onPressed: () {
		    	    // Write some code to control things, when user press back button in AppBar
		    	    moveToLastScreen();
				    }
		    ),
	    ),

	    body: 
      
      Padding(
		    padding: EdgeInsets.all(2.0),
		    child: 
        Card(
          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15.0),),
    child: 
        ListView(
			    children: <Widget>[
            Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
              //dropdown menu
				    child :new ListTile(
              leading: const Icon(Icons.low_priority),
					    title: DropdownButton
              (
							    items: _priorities.map((String dropDownStringItem) {
							    	return DropdownMenuItem<String>
                     (
									    value: dropDownStringItem,
									    child: Text(dropDownStringItem, style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey)),
								     );
							    }).toList(),
							    value: getPriorityAsString(note.priority),
							    onChanged: (valueSelectedByUser) {
							    	setState(() {
							    	  updatePriorityAsInt(valueSelectedByUser);
							    	});
							    }
					    ),
				    ),
            ),
				    // Second Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: titleController,
						    style: textStyle,
						    onChanged: (value) 
                {
						    	updateTitle();
						    },
						    decoration: InputDecoration(
							    labelText: 'Título',
							    labelStyle: textStyle,
                   icon: Icon(Icons.title),
						    ),
					    ),
				    ),

				    // Third Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: descriptionController,
						    style: textStyle,
						    onChanged: (value)
                 {
							    updateDescription();
						    },
						    decoration: InputDecoration(
								    labelText: 'Detalles',
                    icon: Icon(Icons.details),
						    ),
					    ),
				    ),

				    // Fourth Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: Row(
						    children: <Widget>[
						    	Expanded(
								    child: RaisedButton(
									   textColor: Colors.white,
                    color: Colors.green,
                       padding: const EdgeInsets.all(8.0),			
									    child: Text(
										    'Guardar',
										    textScaleFactor: 1.5,
									    ),
									    onPressed: () {
									    	setState(() {
									    	  debugPrint("Pulsado guardar");
									    	  _save();
									    	});
									    },
								    ),
							    ),

							    Container(width: 5.0,),

							    Expanded(
								    child: RaisedButton(
                       textColor: Colors.white,
                    color: Colors.red,
                    padding: const EdgeInsets.all(8.0),						
									    child: Text(
										    'Borrar',
										    textScaleFactor: 1.5,
									    ),
									    onPressed: () {
										    setState(() {
											    _delete();
										    });
									    },
								    ),
							    ),

						    ],
					    ),
				    ),

			    ],
		    ),
        ),
	    ),

    ));
  }



  void moveToLastScreen() {
		Navigator.pop(context, true);
  }

	// Convert the String priority in the form of integer before saving it to Database
	void updatePriorityAsInt(String value) {
		switch (value) {
			case 'High':
				note.priority = 1;
				break;
			case 'Low':
				note.priority = 2;
				break;
		}
	}

  // Convert int priority to String priority and display it to user in DropDown
	String getPriorityAsString(int value) {
		String priority;
		switch (value) {
			case 1:
				priority = _priorities[0];  // 'High'
				break;
			case 2:
				priority = _priorities[1];  // 'Low'
				break;
		}
		return priority;
	}

  // Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDescription() {
		note.description = descriptionController.text;
	}

  void _save() async {

		moveToLastScreen();

		note.date = DateFormat.yMMMd().format(DateTime.now());
		int result;

    if (note.id != null) {  // Case 1: Update operation
			result = await helper.updateItem(note);
		}
    else { // Case 2: Insert Operation
			result = await helper.insertNote(note);
		}
    if (result != 0) {  // Success
			_showAlertDialog('Status', 'Grabado correcto');
		} else {  // Failure
			_showAlertDialog('Status', 'Error en la grabación');
		}
  }

  void _delete() async {

		moveToLastScreen();

		// Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
		// the detail page by pressing the FAB of NoteList page.
		if (note.id == null) {
			_showAlertDialog('Status', 'Anadida primera');
			return;
		}

		// Case 2: User is trying to delete the old note that already has a valid ID.
		int result = await helper.deleteItem(note.id);
		if (result != 0) {
			_showAlertDialog('Status', 'Tarea borrada ');
		} else {
			_showAlertDialog('Status', 'Error');
		}
	}

  void _showAlertDialog(String title, String message) {

		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}

}
