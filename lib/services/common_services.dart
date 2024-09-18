import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  final String host = 'ap-southeast-1.sftpcloud.io';
  final int port = 22;
  final String username = 'flutterDev';
  final String password = 'qLvS8YEjqZBpCRjnVvzBT9SvYdYtNFEE';

  static Future<DateTime?> selectDate(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default starting date
      firstDate: DateTime(1900), // Start date
      lastDate: DateTime.now(), // End date (today)
    );
  }

  static Future<Uint8List> generatePdf({
    required String name,
    required String age,
    required String email,
    required String dob,
    required String gender,
    required String employmentStatus,
    required String address,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Personal Information',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Name: $name', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Age: $age', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Email: $email', style: pw.TextStyle(fontSize: 18)),
            pw.Text('DOB: $dob', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Gender: $gender', style: pw.TextStyle(fontSize: 18)),
            pw.Text('Employment Status: $employmentStatus',
                style: pw.TextStyle(fontSize: 18)),
            pw.Text('Address: $address', style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );

    print("About to save -------------------");
    return await pdf.save();
  }

  Future<File> savePdfToFile(Uint8List pdfBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/personal_info.pdf');
    return await file.writeAsBytes(pdfBytes);
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (_) => pdfBytes);
  }

  static Future<void> uploadPdfToSFTP(Uint8List pdfBytes, String name) async {
    String formattedName = name.replaceAll(' ', '_').toLowerCase();
    final socket = await SSHSocket.connect("ap-southeast-1.sftpcloud.io", 22);
    final client = SSHClient(
      socket,
      username: "flutterDev",
      onPasswordRequest: () => "qLvS8YEjqZBpCRjnVvzBT9SvYdYtNFEE",
    );
    final sftp = await client.sftp();
    final String remoteFilePath = '/$formattedName/personal_information.pdf';
    try {
      await sftp.mkdir('/$formattedName');
      final file =
          await sftp.open(remoteFilePath, mode: SftpFileOpenMode.write);
      // await file.writeBytes(utf8.encode(pdfBytes.toString()));
      final pdfStream = Stream<Uint8List>.fromIterable([pdfBytes]);
      await file.write(pdfStream);
      await file.close();

      print('PDF uploaded to SFTP successfully.');
    } catch (e) {
      print('Failed to upload PDF: $e');
    } finally {
      // Close the SFTP session and the client
      sftp.close();
      client.close();
    }
  }

  static Future<void> removeFileFromServer({required String name}) async {
    String formattedName = name.replaceAll(' ', '_').toLowerCase();
    final socket = await SSHSocket.connect("ap-southeast-1.sftpcloud.io", 22);
    final client = SSHClient(
      socket,
      username: "flutterDev",
      onPasswordRequest: () => "qLvS8YEjqZBpCRjnVvzBT9SvYdYtNFEE",
    );
    final String remoteFilePath = '/$formattedName/personal_information.pdf';
    final sftp = await client.sftp();
    await sftp.remove(remoteFilePath);
  }

  static Future<void> uploadPDFToFirebase(
      {required Uint8List pdfFile, required String username}) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      Reference ref = storage
          .ref()
          .child("$username/${DateTime.now().millisecondsSinceEpoch}.pdf");

      UploadTask uploadTask = ref.putData(pdfFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      print("PDF uploaded successfully. Download URL: $downloadURL");
    } catch (e) {
      print("Failed to upload PDF: $e");
    }
  }

  static Future<void> storeUserData(Map<String, dynamic> jsonData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("User entered data: $jsonData");

    String jsonString = jsonEncode(jsonData);

    await prefs.setString('user_personal_information', jsonString);

    print('JSON data stored successfully');
  }

  static Future<void> removeUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove the specific key
    await prefs.remove('user_personal_information');

    print('Key user_personal_information removed from SharedPreferences.');
  }

  static Future<Map<String, dynamic>?> getJsonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString('user_personal_information');

    if (jsonString != null) {
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      print('JSON data retrieved successfully');
      return jsonData;
    }

    return null; // No data found
  }
}
