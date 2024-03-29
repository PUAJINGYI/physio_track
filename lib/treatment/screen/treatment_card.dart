import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../translations/locale_keys.g.dart';

class TreatmentCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool initialCheckboxValue;

  TreatmentCard({
    required this.icon,
    required this.title,
    required this.initialCheckboxValue,
  });

  @override
  _TreatmentCardState createState() => _TreatmentCardState();
}

class _TreatmentCardState extends State<TreatmentCard> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialCheckboxValue;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Card(
        color: Colors.orange[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 48.0,
                color: Colors.black,
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                            ),
                          ),
                        ),
                        Text(
                          LocaleKeys.Set.tr(),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                            ),
                          ),
                        ),
                        Text(
                          LocaleKeys.Rep.tr(),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
    
              SizedBox(width: 16.0),
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
