import 'package:flutter/material.dart';
import 'package:flutterfitapp/design/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'api_schedule.dart';

final logger = Logger();

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> schedules = [];
  late GetMethods getMethods;
  late PostMethods postMethods;
  late DeleteMethods deleteMethods;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    getMethods = GetMethods();
    postMethods = PostMethods();
    deleteMethods = DeleteMethods();

    final scheduleList = await getMethods.getSchedule();
    setState(() {
      schedules = scheduleList;
      isLoading = false;
    });
  }

  Future<void> _refreshSchedules() async {
    setState(() {
      isLoading = true;
    });
    final scheduleList = await getMethods.getSchedule();
    setState(() {
      schedules = scheduleList;
      isLoading = false;
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No date';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduleDate = DateTime(date.year, date.month, date.day);

      if (scheduleDate == today) {
        return 'Today';
      } else if (scheduleDate == today.add(Duration(days: 1))) {
        return 'Tomorrow';
      } else if (scheduleDate == today.subtract(Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: MyColors.blue_color,
        title: Text(
          'Scheduled Workouts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshSchedules,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSchedules,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Секция с кнопкой создания расписания
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MyColors.blue_color.withOpacity(0.1),
                      MyColors.blue_color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: MyColors.blue_color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: MyColors.blue_color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: MyColors.blue_color,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule a workout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Plan your training sessions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/schedule/add');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.blue_color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Заголовок списка расписаний
              if (!isLoading && schedules.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'Scheduled workouts (${schedules.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],

              // Индикатор загрузки
              if (isLoading)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: MyColors.blue_color,
                    ),
                  ),
                )
              // Пустое состояние
              else if (schedules.isEmpty)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.schedule,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'No scheduled workouts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Schedule your first workout',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Список запланированных тренировок
              else
                Column(
                  children: schedules.map((schedule) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 400,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Градиентный фон
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    MyColors.blue_color.withOpacity(0.05),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Заголовок и меню
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            context.push('/schedule/view', extra: schedule['id']);
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 4),
                                            child: Text(
                                              schedule['name'] ?? 'Unnamed workout',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 22,
                                                color: Colors.grey[800],
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_vert,
                                            color: Colors.grey[600],
                                            size: 20,
                                          ),
                                          offset: Offset(0, 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'view',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.visibility_outlined, size: 18, color: Colors.grey[600]),
                                                  SizedBox(width: 12),
                                                  Text('View'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                                                  SizedBox(width: 12),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline, size: 18, color: Colors.red[400]),
                                                  SizedBox(width: 12),
                                                  Text('Delete', style: TextStyle(color: Colors.red[400])),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (value) async {
                                            if (value == 'view') {
                                              context.push('/schedule/view', extra: schedule['id']);
                                            } else if (value == 'edit') {
                                              context.push('/schedule/edit', extra: schedule['id']);
                                            } else if (value == 'delete') {
                                              await deleteMethods.deleteFutureTraining(schedule['id']);
                                              _refreshSchedules();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12),

                                  // Дата
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: MyColors.blue_color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: MyColors.blue_color.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: MyColors.blue_color,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _formatDate(schedule['date']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: MyColors.blue_color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 12),

                                  // Заметки
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Notes',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          schedule['notes']?.isNotEmpty == true
                                              ? schedule['notes']
                                              : 'No notes added',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: schedule['notes']?.isNotEmpty == true
                                                ? Colors.grey[600]
                                                : Colors.grey[400],
                                            height: 1.4,
                                            fontStyle: schedule['notes']?.isNotEmpty == true
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  // Кнопка запуска
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Пустая ссылка для старта
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: MyColors.blue_color,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_arrow, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Start workout',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}