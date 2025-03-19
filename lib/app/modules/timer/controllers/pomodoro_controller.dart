import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/timer/views/pomodoro_completion_view.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
class PomodoroController extends GetxController {
  RxInt selectedWorkTime = 45.obs; // Default work time in minutes
  RxInt selectedBreakTime = 15.obs; // Default break time in minutes
  RxString selectedLabel = "Work".obs;
  RxBool isRunning = false.obs;
  RxBool isBreakTime = false.obs;
  RxInt remainingSeconds = 0.obs;
  Timer? timer;
  
  // Added number of intervals feature
  RxInt selectedIntervals = 4.obs; // Default intervals
  RxInt currentInterval = 0.obs; // Current interval tracker
  
  // For custom labels
  RxList<String> labelOptions = ["Work", "Study", "Sleep", "Focus", "Create"].obs;
  TextEditingController newLabelController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    remainingSeconds.value = selectedWorkTime.value * 60;
  }

  @override
  void onClose() {
    timer?.cancel();
    newLabelController.dispose();
    super.onClose();
  }

  void startTimer() {
    isRunning.value = true;
    if (currentInterval.value == 0) {
      // First start - reset interval counter
      currentInterval.value = 1;
    }
    
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        // Timer completed
        if (isBreakTime.value) {
          // Break time finished
          currentInterval.value++;
          
          // Check if we've completed all intervals
          if (currentInterval.value > selectedIntervals.value) {
            // All intervals completed
            timer.cancel();
            isRunning.value = false;
            isBreakTime.value = false;
            currentInterval.value = 0;
            remainingSeconds.value = selectedWorkTime.value * 60;
            Get.off(() => CompletionScreen(type: 'all', duration: selectedWorkTime.value * selectedIntervals.value));
            return;
          }
          
          // Still have intervals to go, switch to work time
          isBreakTime.value = false;
          remainingSeconds.value = selectedWorkTime.value * 60;
          Get.off(() => CompletionScreen(type: 'break', duration: selectedBreakTime.value, currentInterval: currentInterval.value, totalIntervals: selectedIntervals.value));
        } else {
          // Work time finished
          
          // Check if it's the last interval, if so, no break needed
          if (currentInterval.value >= selectedIntervals.value) {
            // All intervals completed
            timer.cancel();
            isRunning.value = false;
            isBreakTime.value = false;
            currentInterval.value = 0;
            remainingSeconds.value = selectedWorkTime.value * 60;
            Get.off(() => CompletionScreen(type: 'all', duration: selectedWorkTime.value * selectedIntervals.value));
            return;
          }
          
          // Not the last interval, switch to break time
          isBreakTime.value = true;
          remainingSeconds.value = selectedBreakTime.value * 60;
          Get.off(() => CompletionScreen(type: 'work', duration: selectedWorkTime.value, currentInterval: currentInterval.value, totalIntervals: selectedIntervals.value));
        }
      }
    });
  }

  void stopTimer() {
    Get.defaultDialog(
      title: "Give Up?",
      middleText: "Are you sure you want to give up this session?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      buttonColor: kprimaryColor,
      backgroundColor: Colors.white,
      titleStyle: TextStyle(color: Colors.black),
      middleTextStyle: TextStyle(color: Colors.black54),
      onConfirm: () {
        timer?.cancel();
        isRunning.value = false;
        isBreakTime.value = false;
        currentInterval.value = 0;
        remainingSeconds.value = selectedWorkTime.value * 60;
        Get.back(); // Close Dialog
      },
      onCancel: () {
        Get.back(); // Close Dialog
      },
    );
  }

  void setWorkTime(int minutes) {
    selectedWorkTime.value = minutes;
    if (!isRunning.value && !isBreakTime.value) {
      remainingSeconds.value = minutes * 60;
    }
  }

  void setBreakTime(int minutes) {
    selectedBreakTime.value = minutes;
  }
  
  void setIntervals(int intervals) {
    selectedIntervals.value = intervals;
  }

  void setLabel(String label) {
    selectedLabel.value = label;
  }
  
  void addCustomLabel(String label) {
    if (label.isNotEmpty && !labelOptions.contains(label)) {
      labelOptions.add(label);
      selectedLabel.value = label;
    }
    newLabelController.clear();
  }

  String get formattedTime {
    int minutes = remainingSeconds.value ~/ 60;
    int seconds = remainingSeconds.value % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }
  
  String get progressText {
    return isBreakTime.value 
        ? "Break ${currentInterval.value}/${selectedIntervals.value}" 
        : "Session ${currentInterval.value}/${selectedIntervals.value}";
  }
  
}