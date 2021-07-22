import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

void main() {
  runApp(const MetricsApp());
}

class MetricsApp extends StatelessWidget {
  const MetricsApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview Process Rating',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MetricsHomePage(title: 'Rate your experience with us !'),
    );
  }
}

class MetricsHomePage extends StatefulWidget {
  const MetricsHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MetricsHomePage> createState() => _MetricsHomePageState();
}

class _MetricsHomePageState extends State<MetricsHomePage> {
  /// Controllers for TextFields to post rating
  final _nameController = TextEditingController();
  final _ratingController = TextEditingController();

  /// Scroll controller to handle the horizontal scrolling
  ScrollController _scrollController = ScrollController();

  /// Boolean to hide / show the list of metrics
  bool _displayList = false;

  /// List of the metrics to display per average (onclick)
  var _currentMetrics = [];

  /// Default average period & url
  String? _period = 'day';
  String _url = 'http://localhost:3000/metrics/average/day';

  /// Backend default date format
  final postgresDateFormat = DateFormat("yyyy-MM-ddTH:mm");

  /// Display Default date format
  DateFormat _format = DateFormat('dd/MM/yyyy');
  DateTime now = DateTime.now().toUtc();

  /// Current date formatted with the display date format
  String _currentPeriodDate = "";

  @override
  void initState() {
    _scrollController = ScrollController();
    updateDateVariables();
    super.initState();
  }

  @override
  void dispose() {
    _displayList = false;
    // Clean up the controllers when the widget is disposed.
    _nameController.dispose();
    _ratingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Define the display date format based on the period chosen by the user
  /// Format the current date
  void updateDateVariables() {
    switch (_period) {
      case 'hour':
        _format = DateFormat('dd/MM/yyyy ha');
        break;
      case 'minute':
        _format = DateFormat('dd/MM/yyyy h:mma');
        break;
      default:
        _format = DateFormat('dd/MM/yyyy');
    }
    now = DateTime.now().toUtc();
    _currentPeriodDate = _format.format(now);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    // Make sure to update the variables again because initState only runs once
    updateDateVariables();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MetricsHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          DropdownButton<String>(
            onChanged: (value) {
              // Updating the state of the Widget
              setState(() {
                _displayList = false;
                _period = value;
                _url = 'http://localhost:3000/metrics/average/$_period';
              });
            },
            value: _period,
            items: const [
              DropdownMenuItem(
                value: 'minute',
                child: Text('Minute'),
              ),
              DropdownMenuItem(
                value: 'hour',
                child: Text('Hour'),
              ),
              DropdownMenuItem(
                value: 'day',
                child: Text('Day'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelText: 'Name',
                    ),
                    maxLength: 255,
                    maxLengthEnforcement:
                        MaxLengthEnforcement.truncateAfterCompositionEnds,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _ratingController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelText: 'Rating',
                    ),
                    maxLength: 255,
                    maxLengthEnforcement:
                        MaxLengthEnforcement.truncateAfterCompositionEnds,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your rating';
                      }
                      final n = num.tryParse(value);
                      if (n == null) {
                        return '"$value" is not a valid number';
                      } else if (n < 1 || n > 5) {
                        return 'Rating value must be between 1 and 5';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, save the rating in the database & display a snackbar.
                      await http.post(
                          Uri.parse('http://localhost:3000/metrics'),
                          body: {
                            "name": _nameController.text,
                            "rating": _ratingController.text,
                          });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Rating saved succesfully')));
                      // Reload current page
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    }
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            child: Text(
              'Timeline of average rating per $_period',
              style: const TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            constraints: const BoxConstraints(maxHeight: 100),
            decoration: BoxDecoration(
              color: const Color(0xFF35577D).withOpacity(0.5),
              border: Border.all(width: 1, color: const Color(0xFF35577D)),
            ),
            child: Scrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: FutureBuilder<Response>(
                future: http.get(Uri.parse(_url)),
                builder: futureItemBuilder,
              ),
            ),
          ),
          if (_displayList)
            Container(
              margin: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxHeight: 600, maxWidth: 520),
              child: ListView.separated(
                  itemBuilder: listItemBuilder,
                  separatorBuilder: separatorBuilder,
                  itemCount: _currentMetrics.length),
            )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget futureItemBuilder(
      BuildContext context, AsyncSnapshot<http.Response> snapshot) {
    if (snapshot.hasData) {
      var response = snapshot.data;
      if (response?.statusCode != 200) {
        return const SizedBox.shrink();
      }
      var averageData = jsonDecode(response?.body ?? "[]");
      // Making sure the scrollbar scrolls to the end
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _scrollController.jumpTo(averageData.length * 150);
      });
      // Bilding a timeline tile for each period
      return ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: averageData.length,
          itemBuilder: (BuildContext context, int index) {
            var date =
                _format.format(DateTime.parse(averageData[index]['date']));
            return TimelineTile(
              axis: TimelineAxis.horizontal,
              alignment: TimelineAlign.center,
              isFirst: index == 0,
              isLast: index == averageData.length - 1,
              beforeLineStyle: LineStyle(color: Colors.white.withOpacity(0.8)),
              indicatorStyle: IndicatorStyle(
                color: date == _currentPeriodDate
                    ? Colors.purpleAccent
                    : Colors.white,
                // Add OutlinedButton to make the indicator clickable
                indicator: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        date == _currentPeriodDate
                            ? const Color(0xFF35577D)
                            : Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    _currentMetrics = [];
                    final newDate = postgresDateFormat
                        .format(_format.parse(date, true).toUtc());
                    final response = await http.get(Uri.parse(
                        'http://localhost:3000/metrics?period=$_period&date=$newDate'));
                    if (response.statusCode != 200) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Error retrieving ratings average for that date.')));
                      return;
                    }
                    setState(() {
                      _currentMetrics = jsonDecode(response.body);
                      _displayList = true;
                    });
                  },
                  child: Container(),
                ),
              ),
              startChild: Container(
                constraints: const BoxConstraints(minWidth: 150),
                child: Center(
                  child: Text(
                    date,
                    style: GoogleFonts.sniglet(
                      fontSize: 14,
                      color: date == _currentPeriodDate
                          ? const Color(0xFF35577D)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              endChild: Container(
                constraints: const BoxConstraints(minWidth: 150),
                child: Center(
                  child: Text(
                    averageData[index]['value'],
                    style: GoogleFonts.sniglet(
                      fontSize: 18,
                      color: date == _currentPeriodDate
                          ? const Color(0xFF35577D)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          });
    }
    return ListView(
      controller: _scrollController,
    );
  }

  Widget listItemBuilder(BuildContext context, int index) {
    final dataRow = Row(
      children: [
        SizedBox(
          child: Text(
            _currentMetrics[index]["id"].toString(),
            overflow: TextOverflow.ellipsis,
          ),
          width: 50,
        ),
        SizedBox(
          child: Text(
            _currentMetrics[index]["name"],
            overflow: TextOverflow.ellipsis,
          ),
          width: 200,
        ),
        SizedBox(
          child: Text(
            _currentMetrics[index]["value"].toString(),
            overflow: TextOverflow.ellipsis,
          ),
          width: 70,
        ),
        SizedBox(
          child: Text(
            _format.format(postgresDateFormat
                .parse(_currentMetrics[index]["datetime"], true)
                .toLocal()),
            overflow: TextOverflow.ellipsis,
          ),
          width: 200,
        ),
      ],
    );
    if (index == 0) {
      // If it's the first record, add Header row
      return Column(
        children: [
          Row(
            children: const [
              SizedBox(
                child: Text(
                  "ID",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                width: 50,
              ),
              SizedBox(
                child: Text(
                  "NAME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                width: 200,
              ),
              SizedBox(
                child: Text(
                  "VALUE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                width: 70,
              ),
              SizedBox(
                child: Text(
                  "DATE TIME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                width: 200,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          dataRow,
        ],
      );
    }
    return dataRow;
  }

  Widget separatorBuilder(BuildContext context, int index) {
    return const Divider(
      color: Colors.grey,
      thickness: 2,
    );
  }
}
