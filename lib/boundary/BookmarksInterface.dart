import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookmarksInterface extends StatefulWidget {
  BookmarksInterface({Key? key}) : super(key: key);

  @override
  _BookmarksInterfaceState createState() => _BookmarksInterfaceState();
}
class _BookmarksInterfaceState extends State<BookmarksInterface> 
{
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(AppLocalizations.of(context)!.bookmarksButton,
          style: TextStyle(color:Colors.white) ),
      ),
      backgroundColor: Colors.black,
    );
    
  }
  
}