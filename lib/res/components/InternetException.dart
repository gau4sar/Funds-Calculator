import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';

class InternetExceptionWidget extends StatefulWidget {
  final VoidCallback onPress;

  const InternetExceptionWidget({Key? key, required this.onPress})
      : super(key: key);

  @override
  State<InternetExceptionWidget> createState() =>
      _InternetExceptionWidgetState();
}

class _InternetExceptionWidgetState extends State<InternetExceptionWidget> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Center(
        child: Column(children: [
          SizedBox(height: height * 0.15),
          Icon(
            Icons.cloud_off,
            color: AppColor.blackColor,
            size: height * 0.15,
          ),
          Text(
            'internet_exception'.tr,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * 0.15),
          InkWell(
            onTap: widget.onPress,
            child: Container(
              decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(50)),
              height: 44,
              child: Text('Retry', textAlign: TextAlign.center),
            ),
          )
        ]),
      ),
    );
  }
}
