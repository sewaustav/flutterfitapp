import 'package:flutter/material.dart';
import 'package:flutterfitapp/pages/other/kbju.dart';

import '../../../design/colors.dart';

class CalculateNut extends StatefulWidget {
  const CalculateNut({super.key});

  @override
  State<CalculateNut> createState() => _CalculateNutState();
}

class _CalculateNutState extends State<CalculateNut> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isMale = true;
  ActivityLevel _selectedActivity = ActivityLevel.moderate;
  Purpose _selectedPurpose = Purpose.maintain;

  Map<String, double>? _results;
  double? _totalCalories;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculateNutrients() {
    if (_formKey.currentState!.validate()) {
      final person = Person(
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        activity: _selectedActivity,
        purpose: _selectedPurpose,
        isMale: _isMale,
      );

      final brmCalculator = BrmCalculator(person);
      final totalCalories = brmCalculator.calculate();

      final nutrientCalculator = NutrientCalculator(person, totalCalories);
      final nutrients = nutrientCalculator.calculate();

      setState(() {
        _totalCalories = totalCalories;
        _results = nutrients;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _weightController.clear();
      _heightController.clear();
      _ageController.clear();
      _isMale = true;
      _selectedActivity = ActivityLevel.moderate;
      _selectedPurpose = Purpose.maintain;
      _results = null;
      _totalCalories = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.blue_color,
        title: const Text(
          'Nutrition Calculator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Card
              _buildCard(
                title: 'Personal Information',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _weightController,
                          label: 'Weight (kg)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Enter weight';
                            final weight = double.tryParse(value!);
                            if (weight == null || weight <= 0) return 'Invalid weight';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _heightController,
                          label: 'Height (cm)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Enter height';
                            final height = double.tryParse(value!);
                            if (height == null || height <= 0) return 'Invalid height';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ageController,
                    label: 'Age (years)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Enter age';
                      final age = int.tryParse(value!);
                      if (age == null || age <= 0 || age > 120) return 'Invalid age';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildGenderSelector(),
                ],
              ),

              const SizedBox(height: 20),

              // Activity Level Card
              _buildCard(
                title: 'Activity Level',
                children: [
                  _buildActivitySelector(),
                ],
              ),

              const SizedBox(height: 20),

              // Goal Card
              _buildCard(
                title: 'Goal',
                children: [
                  _buildPurposeSelector(),
                ],
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      onPressed: _clearForm,
                      text: 'Clear',
                      isSecondary: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildButton(
                      onPressed: _calculateNutrients,
                      text: 'Calculate',
                    ),
                  ),
                ],
              ),

              // Results
              if (_results != null) ...[
                const SizedBox(height: 30),
                _buildResultsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Place for SVG icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: MyColors.blue_color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                // Your SVG icon will go here
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
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
          borderSide: BorderSide(color: MyColors.blue_color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                title: 'Male',
                isSelected: _isMale,
                onTap: () => setState(() => _isMale = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                title: 'Female',
                isSelected: !_isMale,
                onTap: () => setState(() => _isMale = false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? MyColors.blue_color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? MyColors.blue_color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Place for SVG icon
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? MyColors.blue_color : Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
              // Your SVG icon will go here
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? MyColors.blue_color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelector() {
    final activities = [
      ('Low (sedentary)', ActivityLevel.low),
      ('Light (1-3 days/week)', ActivityLevel.light),
      ('Moderate (3-5 days/week)', ActivityLevel.moderate),
      ('High (6-7 days/week)', ActivityLevel.high),
      ('Very High (2x/day)', ActivityLevel.veryHigh),
    ];

    return Column(
      children: activities.map((activity) {
        final isSelected = _selectedActivity == activity.$2;
        return GestureDetector(
          onTap: () => setState(() => _selectedActivity = activity.$2),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? MyColors.blue_color.withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: isSelected ? MyColors.blue_color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Place for SVG icon
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? MyColors.blue_color : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // Your SVG icon will go here
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    activity.$1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? MyColors.blue_color : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurposeSelector() {
    final purposes = [
      ('Weight Loss', Purpose.loss),
      ('Maintain Weight', Purpose.maintain),
      ('Weight Gain', Purpose.gain),
    ];

    return Row(
      children: purposes.map((purpose) {
        final isSelected = _selectedPurpose == purpose.$2;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPurpose = purpose.$2),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? MyColors.blue_color.withOpacity(0.1) : Colors.grey[50],
                border: Border.all(
                  color: isSelected ? MyColors.blue_color : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Place for SVG icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? MyColors.blue_color : Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    // Your SVG icon will go here
                  ),
                  const SizedBox(height: 8),
                  Text(
                    purpose.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? MyColors.blue_color : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    bool isSecondary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.grey[200] : MyColors.blue_color,
        foregroundColor: isSecondary ? Colors.grey[700] : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MyColors.blue_color, MyColors.blue_color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColors.blue_color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              // Place for SVG icon
              SizedBox(width: 24, height: 24),
              SizedBox(width: 12),
              Text(
                'Your Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Calories
          _buildResultItem(
            label: 'Daily Calories',
            value: '${_totalCalories!.round()}',
            unit: 'kcal',
            isMain: true,
          ),

          const SizedBox(height: 20),

          // Macronutrients
          Row(
            children: [
              Expanded(
                child: _buildResultItem(
                  label: 'Protein',
                  value: '${_results!['protein']!.round()}',
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultItem(
                  label: 'Fats',
                  value: '${_results!['fats']!.round()}',
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultItem(
                  label: 'Carbs',
                  value: '${_results!['carbohydrates']!.round()}',
                  unit: 'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem({
    required String label,
    required String value,
    required String unit,
    bool isMain = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMain ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMain ? 14 : 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isMain ? 8 : 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isMain ? 28 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: isMain ? 14 : 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}