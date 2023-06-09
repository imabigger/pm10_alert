import 'package:dusty_dust/const/colors.dart';
import 'package:dusty_dust/const/regions.dart';
import 'package:flutter/material.dart';

typedef OnRegionTap = void Function(String region);

class MainDrawer extends StatelessWidget {
  final OnRegionTap onRegionTap;
  final String selectedRegion;

  const MainDrawer(
      {required this.selectedRegion, required this.onRegionTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: darkColor,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              '지역 선택',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          ...regions
              .map((e) => ListTile(
                    tileColor: Colors.white,
                    selectedTileColor: lightColor,
                    selectedColor: Colors.black,
                    selected: selectedRegion==e,
                    onTap: () {
                      onRegionTap(e);
                    },
                    title: Text(e),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
