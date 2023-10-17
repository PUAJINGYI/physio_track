import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:physio_track/screening_test/screen/admin/daily_question_list_screen.dart';
import 'package:physio_track/screening_test/screen/admin/lower_question_list_screen.dart';
import 'package:physio_track/screening_test/screen/admin/upper_question_list_screen.dart';

import '../../../constant/ImageConstant.dart';
import 'general_question_list_screen.dart';

class QuestionListNavPage extends StatefulWidget {
  const QuestionListNavPage({super.key});

  @override
  State<QuestionListNavPage> createState() => _QuestionListNavPageState();
}

class _QuestionListNavPageState extends State<QuestionListNavPage> {
  void initState() {
    super.initState();
    setState(() {});
  }

  int _selectedIndex = 0;

  static List<Widget> _pages = [
    GeneralQuestionListScreen(),
    UpperQuestionListScreen(),
    LowerQuestionListScreen(),
    DailyQuestionListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 25,
            left: 0,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 35.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 25,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                size: 35.0,
              ),
              onPressed: () {
                // Perform your desired action here
                // For example, show notifications
              },
            ),
          ),
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              child: Text(
                'Screening Test',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 0,
            left: 0,
            child: Image.asset(
              ImageConstant.SCREENING_TEST_ADMIN,
              width: 271.0,
              height: 170.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 250),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TestNavigationBarItem(
                          label: 'General',
                          isSelected: _selectedIndex == 0,
                          onTap: () => _onItemTapped(0),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TestNavigationBarItem(
                          label: 'Upper',
                          isSelected: _selectedIndex == 1,
                          onTap: () => _onItemTapped(1),
                        ),
                      ),
                       SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TestNavigationBarItem(
                          label: 'Lower',
                          isSelected: _selectedIndex == 2,
                          onTap: () => _onItemTapped(2),
                        ),
                      ),
                       SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TestNavigationBarItem(
                          label: 'Daily',
                          isSelected: _selectedIndex == 3,
                          onTap: () => _onItemTapped(3),
                        ),
                      ),
                    ],
                  ),
                ), // Adds spacing between text and underline
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TestNavigationBarItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TestNavigationBarItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4), // Adds spacing between text and underline
          Container(
            height: 2,
            width: isSelected ? 150 : 0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
