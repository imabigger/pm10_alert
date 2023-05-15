import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/model/stat_adn_status_model.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/utills/data_utills.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../const/colors.dart';
import '../component/main_card.dart';
import '../component/main_stat.dart';

class CategoryCard extends StatelessWidget {
  final String region;
  final Color darkColor;
  final Color lightColor;

  const CategoryCard(
      {required this.lightColor,
      required this.darkColor,
      required this.region,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: MainCard(
        backgroundColor: lightColor,
        child: LayoutBuilder(builder: (context, constraint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardTitle(
                title: '종류별 통계',
                backgroundColor: darkColor,
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: PageScrollPhysics(),
                  children: ItemCode.values
                      .map(
                        (itemCode) => ValueListenableBuilder(
                          valueListenable:
                              Hive.box<StatModel>(itemCode.name).listenable(),
                          builder: (context, box, widget) {
                            final status =
                                DataUtils.getStatusFromItemCodeAndValue(
                              value: box.values.last.getLevelFromRegion(region),
                              itemCode: itemCode,
                            );

                            return MainStat(
                                category: DataUtils.getItemCodeKrString(
                                    itemCode: itemCode),
                                imgPath: status.imagePath,
                                level: status.name,
                                stat:
                                    '${box.values.last.getLevelFromRegion(region)}${DataUtils.getUnitFromItemCode(itemCode: itemCode)}',
                                width: constraint.maxWidth / 3);
                          },
                        ),
                      )
                      .toList(),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
