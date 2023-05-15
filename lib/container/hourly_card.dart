import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/utills/data_utills.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HourlyCard extends StatelessWidget {
  final Color darkColor;
  final Color lightColor;
  final String region;
  final ItemCode itemCode;

  const HourlyCard({
    required this.lightColor,
    required this.darkColor,
    required this.region,
    required this.itemCode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainCard(
      backgroundColor: lightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardTitle(
            backgroundColor: darkColor,
            title: '시간별 ${DataUtils.getItemCodeKrString(itemCode: itemCode)}',
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box<StatModel>(itemCode.name).listenable(),
            builder: (BuildContext context, box, Widget? child) {
              final stats = box.values.toList().reversed;

              return Column(
                children: stats.map(
                        (stat) => renderRow(stat: stat)
                ).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget renderRow({required StatModel stat}) {
    final status = DataUtils.getStatusFromItemCodeAndValue(
      value: stat.getLevelFromRegion(region),
      itemCode: stat.itemCode,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text('${stat.dataTime.hour}시')),
          Expanded(
            child: Image.asset(
              status.imagePath,
              height: 20.0,
            ),
          ),
          Expanded(
            child: Text(
              status.name,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
