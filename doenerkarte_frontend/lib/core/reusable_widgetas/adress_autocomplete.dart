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
          color: Colors.white,
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





class CoordinatesPickerAndAutoCompleteAdress extends StatefulWidget {
  final bool isPadded;

  final TextEditingValue? initialValue;
  final void Function(String selectedAdress) onAdressSelected;
  final void Function(double latitude) onLatitudeChanged;
  final void Function(double longitude) onLongitudeChanged;


  const CoordinatesPickerAndAutoCompleteAdress({Key? key, required this.onAdressSelected, required this.onLatitudeChanged, required this.onLongitudeChanged, this.initialValue, this.isPadded = true}) : super(key: key);

  @override
  State<CoordinatesPickerAndAutoCompleteAdress> createState() => _CoordinatesPickerAndAutoCompleteAdressState();
}

//------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------- STATE ---------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------
class _CoordinatesPickerAndAutoCompleteAdressState extends State<CoordinatesPickerAndAutoCompleteAdress> {


  // this attribute tells us wheter the address is on cooldown
  bool isCooldown = false;

  // cooldownduration in Milliseconds
  static const int cooldownDuration = 1000;

  Timer? timer;
  List<SearchInfoDetailed> _searchInfoOtions = <SearchInfoDetailed>[];


  static String _displayStringForOption(SearchInfoDetailed option) {

    return option.addressDetailed.toString();
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.isPadded ? EdgeInsets.all(8) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildAdressAutocomplete(),
          // _buildCoordFields(),
        ],
      ),
    );
  }



  // ----------------------------------------------------------------------------------------------------------------------------------
  // ----------------------------------------------------------- WIDGETS --------------------------------------------------------------
  // ----------------------------------------------------------------------------------------------------------------------------------
  Autocomplete<SearchInfoDetailed> _buildAdressAutocomplete() {
    return Autocomplete<SearchInfoDetailed>(
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<SearchInfoDetailed> onSelected, Iterable<SearchInfoDetailed> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              height: 200.0,
              width: 200,
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final SearchInfoDetailed option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option.addressDetailed.toString()),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      initialValue: widget.initialValue,
      fieldViewBuilder:
          (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {

        return TextField(
          controller: fieldTextEditingController,
        );
      },
      displayStringForOption: _displayStringForOption,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if(this.isCooldown){
          return _searchInfoOtions;
        }
        // this sets the cooldown
        Timer(Duration(milliseconds: cooldownDuration), () async { this.isCooldown = false; });
        this.isCooldown = true;
        //--------
        // check whether the value is empty
        if (textEditingValue.text == '') {
          return const Iterable<SearchInfoDetailed>.empty();
        }
        // get suggestion

        _searchInfoOtions = await addressSuggestionDetailed(textEditingValue.text); // TODO: add copyright notice from OSM and photon
        setState(() {});
        return (_searchInfoOtions);
      },
      // set coordinates
      onSelected: (SearchInfoDetailed selection) {
        widget.onAdressSelected(selection.addressDetailed.toString());
        widget.onLatitudeChanged(selection.point?.latitude?? 0);
        widget.onLongitudeChanged(selection.point?.longitude?? 0);
      },

      // we can generate an custom view of the options
    );
  }

}