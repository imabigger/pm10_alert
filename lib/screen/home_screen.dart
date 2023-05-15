import 'package:dio/dio.dart';
import 'package:dusty_dust/component/card_title.dart';
import 'package:dusty_dust/container/category_card.dart';
import 'package:dusty_dust/container/hourly_card.dart';
import 'package:dusty_dust/component/main_app_bar.dart';
import 'package:dusty_dust/component/main_card.dart';
import 'package:dusty_dust/component/main_drawer.dart';
import 'package:dusty_dust/component/main_stat.dart';
import 'package:dusty_dust/const/colors.dart';
import 'package:dusty_dust/const/data.dart';
import 'package:dusty_dust/const/regions.dart';
import 'package:dusty_dust/const/status_level.dart';
import 'package:dusty_dust/model/stat_adn_status_model.dart';
import 'package:dusty_dust/model/stat_model.dart';
import 'package:dusty_dust/repositary/stat_repository.dart';
import 'package:dusty_dust/utills/data_utills.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String region = regions[0];
  bool isExpanded = true;
  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    scrollController.addListener(scrollListner);
    fetchData();
  }

  @override
  dispose() {
    scrollController.removeListener(scrollListner);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final now = DateTime.now();

      final fetchTime = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
      );

      final box = Hive.box<StatModel>(ItemCode.PM10.name);

      if (box.values.isNotEmpty &&
          box.values.last.dataTime.isAtSameMomentAs(fetchTime)) {
        return;
      }

      List<Future> futures = [];

      for (ItemCode itemCode in ItemCode.values) {
        futures.add(StatRepository.fetchData(itemCode: itemCode));
      }

      final results = await Future.wait(futures); // future list안에 모든걸 한번에 기다림
      for (int i = 0; i < results.length; i++) {
        final itemCode = ItemCode.values[i];

        final box = Hive.box<StatModel>(itemCode.name);

        for (StatModel stat in results[i]) {
          box.put(stat.dataTime.toString(), stat);
        }

        final allKeys = box.keys.toList();
        if (allKeys.length > 24) {
          final deleteKeys = allKeys.sublist(0, allKeys.length - 24);

          box.deleteAll(deleteKeys);
        }
      }
    } on DioError catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('인터넷 연결이 원할하지 않습니다.')));
    }

    /*return ItemCode.values.fold<Map<ItemCode, List<StatModel>>>(
      {},
      (previousValue, itemCode) {
        final box = Hive.box<StatModel>(itemCode.name);

        previousValue.addAll({
          itemCode: box.values.toList(),
        });

        return previousValue;
      },
    );*/
  }

  scrollListner() {
    bool isExpanded = scrollController.offset < 500 - kToolbarHeight;

    if (isExpanded != this.isExpanded) {
      setState(() {
        this.isExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<StatModel>(ItemCode.PM10.name).listenable(),
      builder: (context, box, widget) {

        if(box.values.isEmpty){
          return Center(child:  CircularProgressIndicator(),);
        }

        final pm10recentStat = box.values.toList().last;

        final status = DataUtils.getStatusFromItemCodeAndValue(
          value: pm10recentStat.getLevelFromRegion(region),
          itemCode: ItemCode.PM10,
        );

        return Scaffold(
          drawer: MainDrawer(
            selectedRegion: region,
            onRegionTap: (String region) {
              setState(() {
                this.region = region;
              });
              Navigator.of(context).pop();
            },
          ),
          body: Container(
            color: status.primaryColor,
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchData();
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  MainAppBar(
                    status: status,
                    stat: pm10recentStat,
                    region: region,
                    isExpanded: isExpanded,
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CategoryCard(
                          region: region,
                          lightColor: status.lightColor,
                          darkColor: status.darkColor,
                        ),
                        const SizedBox(height: 16.0),
                        ...ItemCode.values
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: HourlyCard(
                                    darkColor: status.darkColor,
                                    lightColor: status.lightColor,
                                    itemCode: item,
                                    region: region,
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
