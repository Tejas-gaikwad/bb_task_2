import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/common_services.dart';
import '../widgets/common_textfield.dart';
import 'pdf_view_screen.dart'; // For formatting the date

class InfoFormScreen extends StatefulWidget {
  @override
  _InfoFormScreenState createState() => _InfoFormScreenState();
}

class _InfoFormScreenState extends State<InfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String age = '';
  String email = '';
  String dob = '';
  String? gender;
  String? employmentStatus;
  String employeeAddress = '';
  DateTime? _selectedDate;
  List<String> genderOptions = ['Male', 'Female', 'Other'];
  List<String> employmentStatusOptions = ['Employed', 'Unemployed', 'Student'];
  late TextEditingController usernameController;
  late TextEditingController ageController;
  late TextEditingController emailIdController;
  late TextEditingController employeeAddressController;
  Map<String, dynamic>? retrievedData;
  bool makeEditable = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    ageController = TextEditingController();
    emailIdController = TextEditingController();
    employeeAddressController = TextEditingController();
    initializeData();
  }

  initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      retrievedData = await Services.getJsonData();
      if (retrievedData == null) {
        makeEditable = true;
      } else {
        makeEditable = false;
      }
      usernameController.text = retrievedData?['name'] ?? "";
      ageController.text = retrievedData?['age'] ?? "";
      emailIdController.text = retrievedData?['email'] ?? "";
      employeeAddressController.text = retrievedData?['address'] ?? "";
      gender = retrievedData?['gender'] ?? "";
      dob = retrievedData?['dob'] ?? "";
      employmentStatus = retrievedData?['employmentStatus'] ?? "";
      setState(() {});
    });
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
          child: ListView(
            children: [
              CommonTextfield(
                hintText: 'Name',
                enabled: makeEditable,
                controller: usernameController,
                onSaved: (value) {
                  name = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CommonTextfield(
                hintText: "Age",
                controller: ageController,
                enabled: makeEditable,
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  age = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CommonTextfield(
                hintText: 'Email ID',
                controller: emailIdController,
                enabled: makeEditable,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  email = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picked = await Services.selectDate(context);
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                      dob = DateFormat('dd MMM yyyy').format(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: CommonTextfield(
                    enabled: makeEditable,
                    hintText: 'Select your date of birth',
                    controller: TextEditingController(
                      text: dob != ""
                          ? dob
                          : _selectedDate != null
                              ? dob
                              : '',
                    ),
                    validator: (value) {
                      if (_selectedDate == null) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                style: TextStyle(
                    fontSize: 16,
                    color: makeEditable
                        ? Colors.black
                        : Colors.grey.withOpacity(0.9)),
                decoration: InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: makeEditable
                            ? Colors.black
                            : Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: makeEditable
                            ? Colors.black
                            : Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value: ((gender) == "") ? null : gender,
                items: genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(),
                    ),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your Gender';
                  }
                  return null;
                },
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(8),
                decoration: InputDecoration(
                  labelText: "Employment Status",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: makeEditable ? Colors.black : Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: makeEditable
                            ? Colors.black
                            : Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                value:
                    ((employmentStatus ?? "") == "") ? null : employmentStatus,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your Employment Status';
                  }
                  return null;
                },
                items: employmentStatusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    employmentStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              CommonTextfield(
                enabled: makeEditable,
                controller: employeeAddressController,
                maxLines: 3,
                hintText: 'Employee Address',
                onSaved: (value) {
                  employeeAddress = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );

                    _formKey.currentState!.save();

                    print('Name: $name');
                    print('Age: $age');
                    print('Email: $email');
                    print('DOB: $dob');
                    print('Gender: $gender');
                    print('Employment Status: $employmentStatus');
                    print('Employee Address: $employeeAddress');

                    final pdfFile = await Services.generatePdf(
                      address: employeeAddress,
                      age: age,
                      dob: dob,
                      email: email,
                      employmentStatus: employmentStatus ?? "NA",
                      gender: gender ?? "NA",
                      name: name,
                    );

                    final data = {
                      "address": employeeAddress,
                      "age": age,
                      "dob": dob,
                      "email": email,
                      "employmentStatus": employmentStatus ?? "NA",
                      "gender": gender ?? "NA",
                      "name": name,
                    };

                    await Services.uploadPdfToSFTP(pdfFile, name);
                    await Services.storeUserData(data);

                    await Services.uploadPDFToFirebase(
                        pdfFile: pdfFile, username: name);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoFormScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0.0, 0.0),
                        spreadRadius: 1.0,
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              retrievedData == null
                  ? const SizedBox()
                  : Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                makeEditable = !makeEditable;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Text(
                                "Edit",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );
                              await Services.removeUserData();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InfoFormScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: const Text(
                                "Delete",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
