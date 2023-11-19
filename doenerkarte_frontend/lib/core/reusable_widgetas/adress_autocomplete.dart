import 'dart:async';

import 'package:flutter/material.dart';


import '../utils/search_completetion.dart';
import 'package:latlong2/latlong.dart';

class AutocompleteAdress extends StatefulWidget {
  
  final Function(LatLng) onSelected;
  const AutocompleteAdress({super.key, required this.onSelected});

  @override
  State<AutocompleteAdress> createState() => _AutocompleteAdressState();
}

class _AutocompleteAdressState extends State<AutocompleteAdress> {

  Timer? _debounce;
  final textController = TextEditingController();
  Future<List<SearchInfoDetailed>>? searchInfoOtions;
  bool showTiles = true;
  FocusNode focusNode = FocusNode();


  @override
  void initState() {
    focusNode.addListener(() {
      if(!focusNode.hasFocus){
        setState(() {
          showTiles = false;
        });
      }
    });
    textController.addListener(() {
      setState(() {
          if(!(_debounce?.isActive ?? false)) {
            showTiles = true;
            searchInfoOtions = addressSuggestionDetailed(textController.text);
            _debounce = Timer(const Duration(milliseconds: 500), () {
              searchInfoOtions = addressSuggestionDetailed(textController.text);
            });
          }else{
          }
      });
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTextfield(),
        if(showTiles)
          FutureBuilder(
              future: searchInfoOtions, builder: (context, snapshot){
                if(snapshot.hasData){
                  var list = List.generate(snapshot.data!.length, (index) => buildListTile(snapshot, index));
                  return Column(children: list,);
                }
                return Container();
          }),

      ],);
  }

  Widget buildListTile(AsyncSnapshot<List<SearchInfoDetailed>> snapshot, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xa3626262),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
                    textColor: Colors.white,
                    title: Text(snapshot.data![index].addressDetailed.toString()),
                    onTap: (){
                      widget.onSelected(snapshot.data![index].point!);
                      setState(() {
                        showTiles = false;
                      });
                      textController.text = snapshot.data![index].addressDetailed.toString();
                    },
                  ),
      ),
    );
  }


  Container buildTextfield() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),

        child: TextField(


          focusNode: focusNode,
          controller: textController,

          decoration: InputDecoration(
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Search',
          ),),
      );
  }
}