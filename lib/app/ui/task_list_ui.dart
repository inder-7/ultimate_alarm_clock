import 'package:flutter/material.dart';

import 'package:ultimate_alarm_clock/app/utils/constants.dart';

class AlarmListScreen extends StatefulWidget {
  const AlarmListScreen({Key? key}) : super(key: key);

  @override
  State<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends State<AlarmListScreen> {
  // Sample alarm data
  final List<AlarmData> alarms = [
    AlarmData(
      time: const TimeOfDay(hour: 7, minute: 0),
      isActive: true,
      tasks: ['Take medication', 'Prepare breakfast', 'Review today\'s meetings'],
      days: [true, true, true, true, true, false, false],
    ),
    AlarmData(
      time: const TimeOfDay(hour: 8, minute: 30),
      isActive: false,
      tasks: ['Exercise', 'Check emails'],
      days: [true, true, true, true, true, true, true],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To do lists', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          return AlarmCard(
            alarm: alarms[index],
            onTap: () => _editAlarm(context, index),
            onToggle: (value) {
              setState(() {
                alarms[index].isActive = value;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kprimaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _addNewAlarm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewAlarm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(
          alarm: AlarmData(
            time: const TimeOfDay(hour: 8, minute: 0),
            isActive: true,
            tasks: [],
            days: List.filled(7, false),
          ),
          isNewAlarm: true,
        ),
      ),
    );
  }

  void _editAlarm(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmEditScreen(
          alarm: alarms[index],
          isNewAlarm: false,
        ),
      ),
    );
  }
}

class AlarmCard extends StatelessWidget {
  final AlarmData alarm;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const AlarmCard({
    Key? key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: kprimaryColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Switch(
                    value: alarm.isActive,
                    onChanged: onToggle,
                    activeColor: kprimaryColor,
                    inactiveThumbColor: Colors.white.withOpacity(0.5),
                    inactiveTrackColor: Colors.white.withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (int i = 0; i < 7; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: alarm.days[i] ? kprimaryColor : kprimaryColor.withOpacity(0.2),
                        child: Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: TextStyle(
                            color: alarm.days[i] ? Colors.black : Colors.black.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (alarm.tasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tasks:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kprimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...alarm.tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: kprimaryColor, size: 16),
                          const SizedBox(width: 8),
                          Text(task, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AlarmEditScreen extends StatefulWidget {
  final AlarmData alarm;
  final bool isNewAlarm;

  const AlarmEditScreen({
    Key? key,
    required this.alarm,
    required this.isNewAlarm,
  }) : super(key: key);

  @override
  State<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends State<AlarmEditScreen> {
  late TimeOfDay _time;
  late List<bool> _days;
  late List<String> _tasks;
  late bool _isActive;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _time = widget.alarm.time;
    _days = List.from(widget.alarm.days);
    _tasks = List.from(widget.alarm.tasks);
    _isActive = widget.alarm.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNewAlarm ? 'Add Alarm' : 'Edit Alarm',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: kprimaryColor),
            onPressed: () {
              // Save alarm logic would go here
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time picker section
            Center(
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: kprimaryColor,
                            onPrimary: Colors.white,
                            surface: Colors.black,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _time = picked;
                    });
                  }
                },
                child: Text(
                  '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Days of week section
            const Text(
              'REPEAT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kprimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 7; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _days[i] = !_days[i];
                      });
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: _days[i] ? kprimaryColor : kprimaryColor.withOpacity(0.2),
                      child: Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        style: TextStyle(
                          color: _days[i] ? Colors.black : Colors.black.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Tasks section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TASKS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kprimaryColor,
                  ),
                ),
                Text(
                  '${_tasks.length} tasks',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Task input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a new task',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: kprimaryColor.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    if (_taskController.text.isNotEmpty) {
                      setState(() {
                        _tasks.add(_taskController.text);
                        _taskController.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Task list
            if (_tasks.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kprimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _tasks.asMap().entries.map((entry) {
                    int index = entry.key;
                    String task = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: kprimaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _tasks.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Alarm active toggle
            SwitchListTile(
              title: const Text('Alarm active', style: TextStyle(color: Colors.white)),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: kprimaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmData {
  final TimeOfDay time;
  bool isActive;
  List<String> tasks;
  List<bool> days; // 7 days, starting from Monday

  AlarmData({
    required this.time,
    required this.isActive,
    required this.tasks,
    required this.days,
  });
}