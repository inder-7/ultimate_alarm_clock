import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class TimezoneAlarmManager {
  // Initialize timezone data
  static Future<void> initializeTimeZones() async {
    tz_data.initializeTimeZones();
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }
  
  // Get a list of all available timezones
  static List<String> getAllTimezones() {
    return tz.timeZoneDatabase.locations.keys.toList();
  }
  
  // Convert a time from one timezone to local time
  static DateTime convertToLocalTime(DateTime dateTime, String timezone) {
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(dateTime, location);
    return tz.TZDateTime.from(tzDateTime, tz.local).toLocal();
  }
  
  // Schedule an alarm for a specific timezone
  static Future<int> scheduleTimezoneAlarm({
    required String timezone,
    required TimeOfDay time,
    required DateTime date,
    required String title,
    required bool repeating,
    required List<int> repeatDays,
  }) async {
    // Get timezone location
    final location = tz.getLocation(timezone);
    
    // Create a DateTime in the target timezone
    final now = DateTime.now();
    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    // Convert to TZDateTime
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, location);
    
    // Convert back to local time for actual scheduling
    final localScheduledDate = convertToLocalTime(scheduledDate, timezone);
    
    // Here you would call your existing alarm scheduling system
    // with the converted localScheduledDate
    // This is a placeholder for your actual alarm scheduling code
    
    return DateTime.now().millisecondsSinceEpoch; // Return alarm ID
  }
  
  // Auto-detect timezone changes
  static Future<bool> hasTimezoneChanged() async {
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    final String savedTimeZone = await _getSavedTimezone();
    
    if (currentTimeZone != savedTimeZone) {
      await _saveCurrentTimezone(currentTimeZone);
      return true;
    }
    return false;
  }
  
  // Update all alarms if timezone changed
  static Future<void> updateAlarmsForNewTimezone() async {
    // Implement your logic to update all saved alarms based on new timezone
    // This would involve retrieving all alarms, recalculating their times,
    // and rescheduling them
  }
  
  // Helper to save current timezone
  static Future<void> _saveCurrentTimezone(String timezone) async {
    // Implement saving to shared preferences or other storage
  }
  
  // Helper to get saved timezone
  static Future<String> _getSavedTimezone() async {
    // Implement retrieving from shared preferences or other storage
    return ''; // Placeholder
  }
}

// Timezone selector UI widget
class TimezoneSelector extends StatefulWidget {
  final Function(String) onTimezoneSelected;
  final String initialTimezone;
  
  const TimezoneSelector({
    Key? key,
    required this.onTimezoneSelected,
    required this.initialTimezone,
  }) : super(key: key);
  
  @override
  _TimezoneSelectorState createState() => _TimezoneSelectorState();
}

class _TimezoneSelectorState extends State<TimezoneSelector> {
  late String selectedTimezone;
  List<String> timezones = [];
  List<String> filteredTimezones = [];
  TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    selectedTimezone = widget.initialTimezone;
    _loadTimezones();
    
    searchController.addListener(() {
      _filterTimezones(searchController.text);
    });
  }
  
  void _loadTimezones() {
    timezones = TimezoneAlarmManager.getAllTimezones();
    filteredTimezones = List.from(timezones);
  }
  
  void _filterTimezones(String query) {
    setState(() {
      filteredTimezones = timezones
          .where((timezone) => timezone.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Your app's background color
      child: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search timezones...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.black54,
              ),
            ),
          ),
          
          // Timezone list
          Expanded(
            child: ListView.builder(
              itemCount: filteredTimezones.length,
              itemBuilder: (context, index) {
                final timezone = filteredTimezones[index];
                final isSelected = timezone == selectedTimezone;
                
                // Get current time in this timezone for display
                final now = DateTime.now();
                final tzLocation = tz.getLocation(timezone);
                final tzTime = tz.TZDateTime.from(now, tzLocation);
                final timeString = '${tzTime.hour.toString().padLeft(2, '0')}:${tzTime.minute.toString().padLeft(2, '0')}';
                
                return ListTile(
                  title: Text(
                    timezone,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'Current time: $timeString',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
                  tileColor: isSelected ? Colors.green.withOpacity(0.2) : null,
                  onTap: () {
                    setState(() {
                      selectedTimezone = timezone;
                    });
                    widget.onTimezoneSelected(timezone);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// Usage example for creating a timezone-based alarm
class TimezoneAlarmCreator extends StatefulWidget {
  @override
  _TimezoneAlarmCreatorState createState() => _TimezoneAlarmCreatorState();
}

class _TimezoneAlarmCreatorState extends State<TimezoneAlarmCreator> {
  String selectedTimezone = 'America/Los_Angeles'; // Default to California time
  TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 30);
  DateTime selectedDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Set Timezone Alarm', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.green),
      ),
      body: Column(
        children: [
          // Time picker
          ListTile(
            title: Text('Alarm Time', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.green, fontSize: 24),
            ),
            onTap: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: Colors.green,
                        background: Colors.white,
                        surface: Colors.black,
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: Colors.black,
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() {
                  selectedTime = time;
                });
              }
            },
          ),
          
          // Date picker
          ListTile(
            title: Text('Alarm Date', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),
            onTap: () async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: Colors.green,
                        onPrimary: Colors.white,
                        surface: Colors.black,
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: Colors.black,
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            },
          ),
          
          // Timezone selector button
          ListTile(
            title: Text('Timezone', style: TextStyle(color: Colors.white)),
            subtitle: Text(selectedTimezone, style: TextStyle(color: Colors.green)),
            onTap: () {
              _showTimezoneSelector();
            },
            trailing: Icon(Icons.language, color: Colors.green),
          ),
          
          // Local time calculation display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.green.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When this alarm will ring:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<DateTime>(
                      future: _calculateLocalRingTime(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final localTime = snapshot.data!;
                          return Text(
                            '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} in your local time',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          );
                        }
                        return CircularProgressIndicator(color: Colors.green);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Spacer(),
          
          // Save button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text('Save Alarm'),
              onPressed: _saveAlarm,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showTimezoneSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: TimezoneSelector(
            initialTimezone: selectedTimezone,
            onTimezoneSelected: (timezone) {
              setState(() {
                selectedTimezone = timezone;
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
  
  Future<DateTime> _calculateLocalRingTime() async {
    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    
    return TimezoneAlarmManager.convertToLocalTime(
      scheduledDateTime,
      selectedTimezone,
    );
  }
  
  void _saveAlarm() async {
    // Schedule the alarm
    final alarmId = await TimezoneAlarmManager.scheduleTimezoneAlarm(
      timezone: selectedTimezone,
      time: selectedTime,
      date: selectedDate,
      title: 'Timezone Alarm',
      repeating: false,
      repeatDays: [],
    );
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm set successfully!', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back
    Navigator.pop(context);
  }
}

// App initialization code for timezone support
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Initialize timezone data
    await TimezoneAlarmManager.initializeTimeZones();
    
    // Check if timezone has changed since last run
    final hasChanged = await TimezoneAlarmManager.hasTimezoneChanged();
    if (hasChanged) {
      // Update all alarms for the new timezone
      await TimezoneAlarmManager.updateAlarmsForNewTimezone();
    }




}
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTimezoneChange();
    }
  }
  
  Future<void> _checkTimezoneChange() async {
    final hasChanged = await TimezoneAlarmManager.hasTimezoneChanged();
    if (hasChanged) {
      // Update all alarms for the new timezone
      await TimezoneAlarmManager.updateAlarmsForNewTimezone();
      
      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your timezone has changed. All alarms have been updated.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultimate Alarm Clock',
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.green,
          secondary: Colors.green,
          surface: Colors.black,
          background: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
      ),
      home: AlarmHomePage(),
    );
  }
}

// Main alarm list page
class AlarmHomePage extends StatefulWidget {
  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  List<AlarmItem> alarms = [];
  
  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }
  
  Future<void> _loadAlarms() async {
    // Load alarms from storage
    // This is a placeholder - implement with your actual storage method
    
    // Example placeholder data
    setState(() {
      alarms = [
        AlarmItem(
          id: 1,
          time: TimeOfDay(hour: 8, minute: 30),
          isEnabled: true,
          timezone: 'America/Los_Angeles',
          label: 'California Meeting',
          repeatDays: [1, 3, 5], // Mon, Wed, Fri
        ),
        AlarmItem(
          id: 2,
          time: TimeOfDay(hour: 18, minute: 0),
          isEnabled: true,
          timezone: 'Asia/Tokyo',
          label: 'Japan Check-in',
          repeatDays: [2, 4], // Tue, Thu
        ),
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Ultimate Alarm Clock'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            color: Colors.green,
            onPressed: () {
              // Show the current timezone
              final now = DateTime.now();
              final timeZone = now.timeZoneName;
              final offset = now.timeZoneOffset.inHours;
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.black,
                  title: Text('Current Timezone', style: TextStyle(color: Colors.green)),
                  content: Text(
                    'Your current timezone is $timeZone (UTC$offset)',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      child: Text('OK', style: TextStyle(color: Colors.green)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: alarms.isEmpty
          ? Center(
              child: Text(
                'No alarms set yet',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return _buildAlarmTile(alarm);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Navigate to add new alarm page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimezoneAlarmCreator()),
          ).then((_) => _loadAlarms());
        },
      ),
    );
  }
  
  Widget _buildAlarmTile(AlarmItem alarm) {
    // Calculate local time for this alarm
    return FutureBuilder<String>(
      future: _getLocalDisplayTime(alarm),
      builder: (context, snapshot) {
        final localTimeString = snapshot.data ?? 'Calculating...';
        
        return Card(
          color: Colors.black,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green.withOpacity(0.3), width: 1),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Text(
                  '${alarm.time.hour.toString().padLeft(2, '0')}:${alarm.time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    alarm.timezone.split('/').last,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.label,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Rings at $localTimeString in your local time',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                _buildRepeatDaysIndicator(alarm.repeatDays),
              ],
            ),
            trailing: Switch(
              value: alarm.isEnabled,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  alarm.isEnabled = value;
                  // Update alarm in storage
                });
              },
            ),
            onTap: () {
              // Navigate to edit alarm page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimezoneAlarmCreator(), // Replace with edit page
                ),
              ).then((_) => _loadAlarms());
            },
          ),
        );
      },
    );
  }
  
  Widget _buildRepeatDaysIndicator(List<int> repeatDays) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: List.generate(7, (index) {
        final isActive = repeatDays.contains(index + 1);
        return Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.transparent,
            border: Border.all(
              color: isActive ? Colors.green : Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              days[index],
              style: TextStyle(
                color: isActive ? Colors.black : Colors.green.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
  
  Future<String> _getLocalDisplayTime(AlarmItem alarm) async {
    // Calculate next occurrence of this alarm
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );
    
    final localTime = await TimezoneAlarmManager.convertToLocalTime(
      alarmTime,
      alarm.timezone,
    );
    
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }
}

// Alarm data model
class AlarmItem {
  final int id;
  final TimeOfDay time;
  bool isEnabled;
  final String timezone;
  final String label;
  final List<int> repeatDays; // 1 = Monday, 7 = Sunday
  
  AlarmItem({
    required this.id,
    required this.time,
    required this.isEnabled,
    required this.timezone,
    required this.label,
    required this.repeatDays,
  });
}