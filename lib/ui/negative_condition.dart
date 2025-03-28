import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlarmConditionController extends GetxController {
  var selectedCondition = "None".obs;
}

class NegativeConditionDropdown extends StatelessWidget {
  final List<String> conditions = [
    "None",
    "Cancel if not at home",
    "Cancel if phone is on silent",
    "Cancel if battery is below 20%",
    "Cancel if connected to Bluetooth",
    "Cancel if a calendar meeting is ongoing",
  ];

  @override
  Widget build(BuildContext context) {
    final AlarmConditionController controller = Get.put(AlarmConditionController());

    return Obx(() => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Condition",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedCondition.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedCondition.value = newValue;
                      }
                    },
                    items: conditions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
