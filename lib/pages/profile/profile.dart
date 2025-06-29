import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/auth/extra_info/api_info.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:flutterfitapp/pages/profile/api_profile.dart';
import 'package:go_router/go_router.dart';

import 'package:flutterfitapp/design/images.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late ApiProfile apiProfile;
  late Goals goals;
  late GetInfo getInfo;
  late Practices practices;
  late ApiExtraInfo apiExtraInfo;

  Map<String, dynamic>? profileInfo;
  Map<String, dynamic>? userInfo;

  List<dynamic>? userGoals;

  String userBmi = '';

  int countPractice = 0;

  double userHeight = 0;
  double userWeight = 0;

  // Variables for goal management
  int? selectedGoalId;
  String selectedGoalTitle = '';
  String selectedGoalDeadline = '';

  @override
  void initState() {
    super.initState();
    apiProfile = ApiProfile();
    goals = Goals();
    getInfo = GetInfo();
    practices = Practices();
    apiExtraInfo = ApiExtraInfo();
    _init();
  }

  Future<void> _init() async {
    List<dynamic> profileInfoData = await apiProfile.getProfileInfo();
    List<dynamic> userGoalsData = await goals.getGoals();
    List<dynamic> userInfoData = await getInfo.getExtraInfo();
    int countPracticeData = await practices.getNumberPractices();
    setState(() {
      profileInfo = profileInfoData[0];
      userGoals = userGoalsData;
      countPractice = countPracticeData;
      userHeight = userInfoData[0]['height'];
      userWeight = userInfoData[0]['weight'];
      userBmi = (userWeight / ((userHeight/100)*(userHeight/100))).toStringAsFixed(2);
    });
  }

  void createGoal() {
    context.go('/add-goal');
  }

  Future<void> _showGoalManagementDialog(Map<String, dynamic> goalItem) async {
    selectedGoalId = goalItem['id']; // Store goal ID
    selectedGoalTitle = goalItem['goal'] ?? '';
    selectedGoalDeadline = goalItem['final_day_of_goal'] ?? '';

    final TextEditingController titleController = TextEditingController(text: selectedGoalTitle);
    final TextEditingController deadlineController = TextEditingController(text: selectedGoalDeadline);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(0xFF327AED).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.flag_outlined,
                        color: Color(0xFF327AED),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Manage Goal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      splashRadius: 20,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Goal Title Input
                Text(
                  'Goal Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter goal title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF327AED), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    selectedGoalTitle = value;
                  },
                ),

                SizedBox(height: 16),

                // Deadline Input with Date Picker
                Text(
                  'Target Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: deadlineController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select target date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF327AED), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[500]),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(), // Ограничиваем выбор от сегодняшнего дня
                      lastDate: DateTime.now().add(Duration(days: 365 * 5)), // Максимум 5 лет в будущее
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Color(0xFF327AED), // Цвет заголовка и выбранной даты
                              onPrimary: Colors.white, // Цвет текста на primary
                              onSurface: Colors.black, // Цвет текста
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Color(0xFF327AED), // Цвет кнопок
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      deadlineController.text = formattedDate;
                      selectedGoalDeadline = formattedDate;
                    }
                  },
                ),

                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Complete Goal Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await apiExtraInfo.completeGoal(selectedGoalId!);
                          List<dynamic> userGoalsData = await goals.getGoals();
                          logger.i('RRRRRRR$userGoalsData');
                          setState(() {
                            userGoals = userGoalsData;
                          });
                        },
                        icon: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.green[600],
                          ),
                        ),
                        label: Text(
                          'Complete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green[600],
                          elevation: 2,
                          shadowColor: Colors.green.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Update Goal Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          Map<String, dynamic> newData = {
                            'goal': selectedGoalTitle,
                            'final_day_of_goal': selectedGoalDeadline
                          };
                          await goals.updateGoals(newData, selectedGoalId!);
                          List<dynamic> userGoalsData = await goals.getGoals();
                          setState(() {
                            userGoals = userGoalsData;
                          });
                        },
                        icon: Icon(Icons.edit_outlined, size: 18),
                        label: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF327AED),
                          elevation: 2,
                          shadowColor: Colors.blue.withOpacity(0.3),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Delete Goal Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await goals.deleteGoal(selectedGoalId!);
                      List<dynamic> userGoalsData = await goals.getGoals();
                      setState(() {
                        userGoals = userGoalsData;
                      });
                    },
                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[600]),
                    label: Text(
                      'Delete Goal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  // Profile Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8B7355),
                    ),
                    child: ClipOval(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Name
                  Text(
                    '${profileInfo?['username']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Title
                ],
              ),
            ),

            SizedBox(height: 16),

            Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: Colors.black26,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Metrics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMetricRow('Height', '$userHeight', human),
                    const SizedBox(height: 12),
                    _buildMetricRow('Weight', '$userWeight', weight),
                    const SizedBox(height: 12),
                    _buildMetricRow('BMI', '$userBmi', bmi),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/add-info', extra: 0),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Change data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.shade600,
                          elevation: 2,
                          shadowColor: Colors.blue.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Goals Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (userGoals != null && userGoals!.isNotEmpty)
                    ...userGoals!.map((goalItem) {
                      final goal = goalItem['goal'];
                      final finalDay = goalItem['final_day_of_goal'];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF327AED).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Color(0xFF327AED).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.flag_outlined,
                                color: Color(0xFF327AED),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.track_changes,
                                        color: Color(0xFF327AED),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          goal ?? 'Goal',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (finalDay != null) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          color: Colors.grey[600],
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Target: $finalDay',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await _showGoalManagementDialog(goalItem);

                              },

                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF327AED).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF327AED),
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.flag_outlined,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No goals set yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Start by setting your fitness goals',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/add-goal'),
                      icon: Icon(Icons.add, size: 20),
                      label: Text(
                        'Add goal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue.shade600,
                        elevation: 2,
                        shadowColor: Colors.blue.withOpacity(0.3),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),

            SizedBox(height: 16),

            // Stats Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      // Workouts Completed
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Workouts\nCompleted',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                '$countPractice',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      // Total Time Trained
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Time\nTrained',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No data',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Settings Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Notifications
                  _buildSettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  SizedBox(height: 8),
                  // Privacy
                  _buildSettingsItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                  SizedBox(height: 8),
                  // Help
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Widget iconWidget) {
    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }


  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}