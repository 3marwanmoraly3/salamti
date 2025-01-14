import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:salamti/importantHotlines/importantHotlines.dart';

class ImportantHotlines extends StatefulWidget {
  const ImportantHotlines({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const ImportantHotlines());
  }

  @override
  State<ImportantHotlines> createState() => _ImportantHotlinesState();
}

class _ImportantHotlinesState extends State<ImportantHotlines> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 20),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Important Hotlines",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_circle_left_rounded,
                size: 60,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.zero,
            ),
          ),
          body: ListView.builder(
            itemCount: hotlinesData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          expandedIndex = expandedIndex == index ? null : index;
                        });
                      },
                      child: _hotlineButton(hotlinesData[index]),
                    ),
                    if (expandedIndex == index)
                      _expandedList(hotlinesData[index]['list']),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _hotlineButton(Map<String, dynamic> hotline) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0x66d9d9d9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hotline["title"],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Icon(
                hotline["icon"],
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandedList(List<dynamic> items) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: const Color(0x33d9d9d9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    items[index]["name"],
                    style: const TextStyle(fontSize: 20),
                    softWrap: true, // Ensures the text wraps
                    overflow: TextOverflow.clip, // Clips any overflow text
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final url = Uri(
                        scheme: 'tel',
                        path:
                        items[index]["number"]);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(
                    Icons.call_rounded,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5ffd95)),
                  iconSize: 24,
                  padding: const EdgeInsets.all(5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}