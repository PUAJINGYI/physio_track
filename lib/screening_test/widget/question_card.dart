import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:physio_track/screening_test/model/question_model.dart';
import 'package:physio_track/screening_test/model/question_response_model.dart';
import '../../notification/widget/shimmering_text_list_widget.dart';
import '../../translations/locale_keys.g.dart';
import '../../translations/service/translate_service.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final List<QuestionResponse> responses;
  final ValueChanged<double> onChanged;
  final BuildContext context; // Added context parameter

  const QuestionCard({
    required this.question,
    required this.responses,
    required this.onChanged,
    required this.context, // Added context parameter to the constructor
  });

  @override
  Widget build(BuildContext context) {
    final responseIndex = responses.indexWhere((r) => r.id == question.id);
    final responseValue = responseIndex != -1
        ? double.tryParse(responses[responseIndex].response) ?? 1.0
        : 1.0;
    TranslateService translateService = TranslateService();
    return Card(
      child: Container(
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: translateService.translateText(
                    question.question, context),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ShimmeringTextListWidget(width: 300, numOfLines: 2),
                      ],
                    ); // or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    String question = snapshot.data!;
                    return Text(
                      question,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),

              SizedBox(height: 8),
              buildQuestionWidget(
                  question.questionType, responseValue, onChanged),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildQuestionWidget(
    String questionType,
    double responseValue,
    ValueChanged<double> onValueChanged,
  ) {
    switch (questionType) {
      case 'scale':
        return buildSlider(responseValue, onValueChanged);
      case 'short':
        return buildTextField(responseValue, onValueChanged);
      case 'date':
        return buildDatePicker(
            responseValue, onValueChanged, context); // Pass the context
      case 'option':
        return buildRadioButton(responseValue, onValueChanged);
      case 'gender':
        return buildGenderRadioButton(responseValue, onValueChanged);
      default:
        return SizedBox.shrink();
    }
  }

  Widget buildSlider(double value, ValueChanged<double> onChanged) {
    final roundedValue =
        value.round(); // Round the value to the nearest integer

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(LocaleKeys.Extreme_Difficulty.tr(),
                style: TextStyle(fontSize: 12)),
            Text(LocaleKeys.No_Difficulty.tr(), style: TextStyle(fontSize: 12)),
          ],
        ),
        Slider(
          value:
              roundedValue.toDouble(), // Use the rounded value for the slider
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (newValue) {
            onChanged(newValue);
          },
          onChangeEnd: (newValue) {
            final roundedNewValue = newValue.round(); // Round the new value
            onChanged(roundedNewValue.toDouble()); // Use the rounded new value
          },
        ),
      ],
    );
  }

  Widget buildTextField(double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: TextField(
        onChanged: (newValue) {
          final parsedValue = double.tryParse(newValue);
          if (parsedValue != null) {
            onChanged(parsedValue);
          }
        },
        keyboardType: TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget buildDatePicker(
    double value,
    ValueChanged<double> onChanged,
    BuildContext context,
  ) {
    final selectedDate = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    final firstDate = DateTime(2000);
    DateTime? newDate = selectedDate;

    final dateFormat = DateFormat('dd-MMM-yyyy'); // Define the date format

    return ListTile(
      title: Text(dateFormat.format(newDate)), // Format the date
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        newDate = await showDatePicker(
          context: context,
          locale: EasyLocalization.of(context)!.currentLocale!,
          initialDate:
              selectedDate.isBefore(firstDate) ? firstDate : selectedDate,
          firstDate: firstDate,
          lastDate: DateTime(2100),
        );

        if (newDate != null) {
          onChanged(newDate!.millisecondsSinceEpoch.toDouble());
        }
      },
    );
  }

  Widget buildRadioButton(double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        RadioListTile<double>(
          title: Text(LocaleKeys.Yes.tr()),
          value: 1.0,
          groupValue: value,
          onChanged: (newValue) {
            onChanged(newValue!);
          },
        ),
        RadioListTile<double>(
          title: Text(LocaleKeys.No.tr()),
          value: 0.0,
          groupValue: value,
          onChanged: (newValue) {
            onChanged(newValue!);
          },
        ),
      ],
    );
  }

  Widget buildGenderRadioButton(double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        RadioListTile<double>(
          title: Text(LocaleKeys.Male.tr()),
          value: 1.0,
          groupValue: value,
          onChanged: (newValue) {
            onChanged(newValue!);
          },
        ),
        RadioListTile<double>(
          title: Text(LocaleKeys.Female.tr()),
          value: 0.0,
          groupValue: value,
          onChanged: (newValue) {
            onChanged(newValue!);
          },
        ),
      ],
    );
  }
}
