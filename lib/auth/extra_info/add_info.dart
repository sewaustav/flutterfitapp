import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfitapp/auth/extra_info/api_info.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../design/colors.dart';

class AddExtraInfo extends StatefulWidget {
  const AddExtraInfo({super.key, required this.go});
  final String go;

  @override
  State<AddExtraInfo> createState() => _AddExtraInfoState();
}

class _AddExtraInfoState extends State<AddExtraInfo> {
  final logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ApiExtraInfo apiExtraInfo;

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _weightController.dispose();
    _heightController.dispose();
  }

  @override
  void initState() {
    super.initState();
    apiExtraInfo = ApiExtraInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.blue_color,
        title: const Text(
          'Fitapp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Заголовок и описание
                const Text(
                  'Enter your body data',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This information can help us your personal program of training.\n\nYou can always check or change it in settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 48),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Height',
                        hintText: 'Enter your height in cm',
                        suffixText: 'cm',
                        suffixStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MyColors.blue_color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.height,
                            color: MyColors.blue_color,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'weight',
                        hintText: 'Enter your weight in kg',
                        suffixText: 'kg',
                        suffixStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MyColors.blue_color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.monitor_weight_outlined,
                            color: MyColors.blue_color,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      apiExtraInfo.postExtraInfo({
                        'weight': _weightController.text,
                        'height': _heightController.text
                      });
                      if (widget.go == '1') {
                        context.push('/add-goal');
                      } else {
                        context.go('/profile');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.blue_color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}