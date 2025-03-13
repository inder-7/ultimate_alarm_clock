import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/settings_controller.dart';
import 'package:ultimate_alarm_clock/app/modules/settings/controllers/theme_controller.dart';
import 'package:ultimate_alarm_clock/app/utils/constants.dart';
import 'package:ultimate_alarm_clock/app/utils/utils.dart';

class FlipToSnooze extends StatefulWidget {
  const FlipToSnooze({
    super.key,
    required this.controller,
    required this.height,
    required this.width,
    required this.themeController,
  });

  final SettingsController controller;
  final ThemeController themeController;

  final double height;
  final double width;

  @override
  State<FlipToSnooze> createState() => _FlipToSnoozeState();
}

class _FlipToSnoozeState extends State<FlipToSnooze> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: widget.width * 0.91,
        height: widget.height * 0.1,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(18),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Flip to Snooze'.tr,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: widget.themeController.primaryTextColor.value),
                ),
              ),
              Obx(
                () => Switch.adaptive(
                  value: widget.controller.isFlipToSnoozeEnabled.value,
                  activeColor: ksecondaryColor,
                  onChanged: (bool value) async {
                    widget.controller.toggleFlipToSnooze(value);
                    Utils.hapticFeedback();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
