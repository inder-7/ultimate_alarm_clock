import 'package:flutter/material.dart';



class AlarmHistoryScreen extends StatefulWidget {
  const AlarmHistoryScreen({Key? key}) : super(key: key);

  @override
  _AlarmHistoryScreenState createState() => _AlarmHistoryScreenState();
}

class _AlarmHistoryScreenState extends State<AlarmHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Missed', 'Snoozed', 'Dismissed'];

  final List<AlarmHistoryItem> _alarmHistory = [
    AlarmHistoryItem(
      id: '1',
      alarmName: 'Morning Run',
      time: '7:00 AM',
      date: 'Today',
      status: AlarmStatus.triggered,
      statusDetail: 'Triggered & Dismissed',
      location: 'Home',
      weather: 'Clear',
      sharedWith: null,
    ),
    AlarmHistoryItem(
      id: '2',
      alarmName: 'Gym',
      time: '6:30 AM',
      date: 'Yesterday',
      status: AlarmStatus.failed,
      statusDetail: 'Failed to Trigger',
      location: 'Unknown',
      weather: 'Rain',
      sharedWith: null,
    ),
    AlarmHistoryItem(
      id: '3',
      alarmName: 'Meeting',
      time: '8:15 AM',
      date: 'Yesterday',
      status: AlarmStatus.snoozed,
      statusDetail: 'Snoozed 3 times',
      location: 'Office',
      weather: 'Cloudy',
      sharedWith: null,
    ),
    AlarmHistoryItem(
      id: '4',
      alarmName: 'Morning Run',
      time: '5:30 AM',
      date: 'Mar 13',
      status: AlarmStatus.triggered,
      statusDetail: 'Triggered (Both)',
      location: 'Park',
      weather: 'Cold',
      sharedWith: 'Sarah',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alarm History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _alarmHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildAlarmCard(_alarmHistory[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      color: Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.black,
              selectedColor: const Color(0xFF2E8B57),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF2E8B57),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlarmCard(AlarmHistoryItem alarm) {
    Color statusColor;
    switch (alarm.status) {
      case AlarmStatus.triggered:
        statusColor = const Color(0xFF2E8B57);
        break;
      case AlarmStatus.failed:
        statusColor = Colors.red;
        break;
      case AlarmStatus.snoozed:
        statusColor = Colors.amber;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${alarm.time} - ${alarm.alarmName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _showAlarmDetails(alarm);
                          },
                          child: Row(
                            children: [
                              Text(
                                'Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      alarm.sharedWith != null
                          ? '${alarm.date}, ${alarm.time} • Shared with ${alarm.sharedWith}'
                          : '${alarm.date}, ${alarm.time}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          alarm.statusDetail,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Location: ${alarm.location}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Weather: ${alarm.weather}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlarmDetails(AlarmHistoryItem alarm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${alarm.time} - ${alarm.alarmName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${alarm.date}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              _detailItem('Status', alarm.statusDetail),
              _detailItem('Location', alarm.location),
              _detailItem('Weather', alarm.weather),
              _detailItem('Device Battery', '85%'),
              _detailItem('Network Status', 'Connected (WiFi)'),
              _detailItem('Background State', 'Active'),
              if (alarm.sharedWith != null)
                _detailItem('Shared With', alarm.sharedWith!),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: Color(0xFF1A1A1A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.access_alarm, color: Colors.white),
            onPressed: () {},
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2E8B57),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {},
            ),
          ),
          IconButton(
            icon: Icon(Icons.history, color: const Color(0xFF2E8B57)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

enum AlarmStatus {
  triggered,
  failed,
  snoozed,
}

class AlarmHistoryItem {
  final String id;
  final String alarmName;
  final String time;
  final String date;
  final AlarmStatus status;
  final String statusDetail;
  final String location;
  final String weather;
  final String? sharedWith;

  AlarmHistoryItem({
    required this.id,
    required this.alarmName,
    required this.time,
    required this.date,
    required this.status,
    required this.statusDetail,
    required this.location,
    required this.weather,
    this.sharedWith,
  });
}