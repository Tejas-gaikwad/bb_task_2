import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/common_services.dart';
import '../widgets/common_textfield.dart';

class InfoFormScreen extends StatefulWidget {
  @override
  _InfoFormScreenState createState() => _InfoFormScreenState();
}

class _InfoFormScreenState extends State<InfoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String dob = '';
  String? gender;
  String? employmentStatus;
  DateTime? _selectedDate;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> employmentStatusOptions = [
    'Employed',
    'Unemployed',
    'Student'
  ];

  late TextEditingController usernameController;
  late TextEditingController ageController;
  late TextEditingController emailIdController;
  late TextEditingController employeeAddressController;

  bool loading = false;
  bool deleteLoading = false;
  Map<String, dynamic>? retrievedData;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    ageController = TextEditingController();
    emailIdController = TextEditingController();
    employeeAddressController = TextEditingController();
    initializeData();
  }

  Future<void> initializeData() async {
    retrievedData = await Services.getJsonData();
    if (retrievedData != null && retrievedData!.isNotEmpty) {
      setState(() {
        usernameController.text = retrievedData?['name'] ?? "";
        ageController.text = retrievedData?['age'] ?? "";
        emailIdController.text = retrievedData?['email'] ?? "";
        employeeAddressController.text = retrievedData?['address'] ?? "";
        gender = retrievedData?['gender'] ?? "";
        dob = retrievedData?['dob'] ?? "";
        employmentStatus = retrievedData?['employmentStatus'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                    "Name", usernameController, "Please enter your name"),
                const SizedBox(height: 20),
                _buildTextField("Age", ageController, "Please enter your age",
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                _buildTextField(
                    "Email ID", emailIdController, "Please enter your email ID",
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildDatePicker(),
                const SizedBox(height: 20),
                _buildDropdownField("Gender", genderOptions, gender,
                    (value) => gender = value, "Please select your Gender"),
                const SizedBox(height: 20),
                _buildDropdownField(
                    "Employment Status",
                    employmentStatusOptions,
                    employmentStatus,
                    (value) => employmentStatus = value,
                    "Please select your Employment Status"),
                const SizedBox(height: 20),
                _buildTextField("Employee Address", employeeAddressController,
                    "Please enter your address",
                    maxLines: 3),
                const SizedBox(height: 20),
                _buildSubmitButton(),
                const SizedBox(height: 20),
                retrievedData != null ? _buildDeleteButton() : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, TextEditingController controller, String validationMessage,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return CommonTextfield(
      hintText: hint,
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked =
            await Services.selectDate(context, DateTime(1999, 12, 14));
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            dob = DateFormat('dd MMM yyyy').format(_selectedDate!);
          });
        }
      },
      child: AbsorbPointer(
        child: CommonTextfield(
          hintText: 'Select your date of birth',
          controller: TextEditingController(text: dob),
          validator: (value) {
            if (dob.isEmpty) {
              return 'Please select your date of birth';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String label,
      List<String> options,
      String? selectedValue,
      Function(String?) onChanged,
      String validationMessage) {
    return DropdownButtonFormField<String>(
      value: ((selectedValue ?? "").isEmpty) ? null : selectedValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      items: options.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      validator: (value) =>
          value == null || value.isEmpty ? validationMessage : null,
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          setState(() => loading = true);
          final data = {
            "name": usernameController.text,
            "age": ageController.text,
            "dob": dob,
            "email": emailIdController.text,
            "gender": gender ?? "NA",
            "employmentStatus": employmentStatus ?? "NA",
            "address": employeeAddressController.text,
          };

          final pdfFile = await Services.generatePdf(
            address: employeeAddressController.text,
            age: ageController.text,
            dob: dob,
            email: emailIdController.text,
            employmentStatus: employmentStatus ?? "NA",
            gender: gender ?? "NA",
            name: usernameController.text,
          );

          if (retrievedData == null) {
            await Services.uploadPdfToSFTP(pdfFile, usernameController.text);
            await Services.storeUserData(data);
            await Services.uploadPDFToFirebase(
                pdfFile: pdfFile, username: usernameController.text);
          } else {
            await Services.uploadAndReplacePdfOnSFTP(
                context, pdfFile, usernameController.text);
            await Services.updatePdfInFirebase(
                pdf: pdfFile, name: usernameController.text);
            await Services.storeUserData(data);
          }

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => InfoFormScreen()));
          setState(() => loading = false);
        }
      },
      child: _buildLoadingButton(
          loading, retrievedData == null ? 'Save' : 'Update'),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: () async {
        setState(() => deleteLoading = true);
        await Services.deletePdfInFirebase();
        await Services.removeFileFromServer();
        await Services.removeUserData();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => InfoFormScreen()));
        setState(() => deleteLoading = false);
      },
      child: _buildLoadingButton(deleteLoading, "Delete", color: Colors.red),
    );
  }

  Widget _buildLoadingButton(bool isLoading, String label,
      {Color color = Colors.black}) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator()))
          : Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}
