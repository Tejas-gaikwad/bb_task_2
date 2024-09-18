import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  final String host = dotenv.env['SFTP_HOST'] ?? "";
  final int port = int.parse(dotenv.env['SFTP_PORT'] ?? "");
  final String username = dotenv.env['SFTP_USERNAME'] ?? "";
  final String password = dotenv.env['SFTP_PASSWORD'] ?? "";
  static SSHClient? _client;
  static SftpClient? _sftp;

  static Future<SftpClient?> initializeSFTP() async {
    if (_client == null) {
      try {
        final socket =
            await SSHSocket.connect("ap-southeast-1.sftpcloud.io", 22);
        _client = SSHClient(
          socket,
          username: "flutterDev",
          onPasswordRequest: () => "qLvS8YEjqZBpCRjnVvzBT9SvYdYtNFEE",
        );
        _sftp = await _client!.sftp();
      } catch (e) {
        print("Error initializing SSH: $e");
      }
    }
    return _sftp;
  }

  static Future<void> disposeSFTP() async {
    if (_client != null) {
      _client?.close();
      _client = null;
    }
  }

  static Future<DateTime?> selectDate(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
            pw.Text('Name: $name', style: const pw.TextStyle(fontSize: 18)),
            pw.Text('Age: $age', style: const pw.TextStyle(fontSize: 18)),
            pw.Text('Email: $email', style: const pw.TextStyle(fontSize: 18)),
            pw.Text('DOB: $dob', style: const pw.TextStyle(fontSize: 18)),
            pw.Text('Gender: $gender', style: const pw.TextStyle(fontSize: 18)),
            pw.Text('Employment Status: $employmentStatus',
                style: const pw.TextStyle(fontSize: 18)),
            pw.Text('Address: $address',
                style: const pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
    return await pdf.save();
  }

  Future<File> savePdfToFile(Uint8List pdfBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/personal_info.pdf');
    return await file.writeAsBytes(pdfBytes);
  }

  static Future<void> uploadPdfToSFTP(Uint8List pdfBytes, String name) async {
    String formattedName = name.replaceAll(' ', '_').toLowerCase();
    final sftp = await Services.initializeSFTP();
    final String remoteFilePath = '/$formattedName/personal_information.pdf';
    try {
      await sftp?.mkdir('/$formattedName');
      final file =
          await sftp?.open(remoteFilePath, mode: SftpFileOpenMode.write);
      final pdfStream = Stream<Uint8List>.fromIterable([pdfBytes]);
      await file?.write(pdfStream);
      await file?.close();
    } catch (e) {
      return;
    } finally {
      await disposeSFTP();
    }
  }

  static Future<void> uploadAndReplacePdfOnSFTP(
    BuildContext context,
    Uint8List pdfBytes,
    String newName,
  ) async {
    final userData = await getJsonData();
    final oldName = userData?['name'] ?? "";

    String formattedOldName = oldName.replaceAll(' ', '_').toLowerCase();
    String formattedNewName = newName.replaceAll(' ', '_').toLowerCase();

    final sftp = await Services.initializeSFTP();
    final String oldRemoteDirectory = '/$formattedOldName';
    final String oldRemoteFilePath =
        '/$formattedOldName/personal_information.pdf';
    final String newRemoteFilePath =
        '/$formattedNewName/personal_information.pdf';
    try {
      try {
        await sftp?.stat(oldRemoteFilePath);
        await sftp?.remove(oldRemoteFilePath);
      } catch (e) {
        return;
      }

      try {
        await sftp?.stat(oldRemoteDirectory);
        await sftp?.rmdir(oldRemoteDirectory);
      } catch (e) {
        return;
      }

      try {
        await sftp?.stat('/$formattedNewName');
      } catch (e) {
        await sftp?.mkdir('/$formattedNewName');
      }
      final file =
          await sftp?.open(newRemoteFilePath, mode: SftpFileOpenMode.write);
      final pdfStream = Stream<Uint8List>.fromIterable([pdfBytes]);
      await file?.write(pdfStream);
      await file?.close();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Data Updated Successfully")));
    } catch (e) {
      return;
    } finally {
      await disposeSFTP();
    }
  }

  static Future<void> removeFileFromServer() async {
    final userData = await getJsonData();
    final name = userData?['name'] ?? "";
    String formattedName = name.replaceAll(' ', '_').toLowerCase();
    final String oldRemoteFilePath = '/$formattedName/personal_information.pdf';
    final String oldRemoteDirectory = '/$formattedName';
    final String remoteFilePath = '/$formattedName/personal_information.pdf';
    final sftp = await Services.initializeSFTP();
    await sftp?.remove(remoteFilePath);
    try {
      await sftp?.stat(oldRemoteFilePath);
      await sftp?.remove(oldRemoteFilePath);
    } catch (e) {
      return;
    }
    try {
      await sftp?.stat(oldRemoteDirectory);
      await sftp?.rmdir(oldRemoteDirectory);
    } catch (e) {
      return;
    }
  }

  static Future<void> uploadPDFToFirebase(
      {required Uint8List pdfFile, required String username}) async {
    try {
      String formattedUserName = username.replaceAll(' ', '_').toLowerCase();
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child("$formattedUserName/personal_information.pdf");
      UploadTask uploadTask = ref.putData(pdfFile);
      TaskSnapshot snapshot = await uploadTask;
      await snapshot.ref.getDownloadURL();
    } catch (e) {
      return;
    }
  }

  static Future<void> updatePdfInFirebase(
      {required Uint8List pdf, required String name}) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? oldPdfUrl = prefs.getString('pdf_url');
    try {
      if (oldPdfUrl != null) {
        try {
          final userData = await getJsonData();
          final oldName = userData?['name'] ?? "";
          String formattedOldName = oldName.replaceAll(' ', '_').toLowerCase();
          final fullPath = "$formattedOldName/personal_information.pdf";
          final oldRef = storage.ref(fullPath);
          await oldRef.delete();
        } catch (e) {
          return;
        }
      }
      String formattedNewName = name.replaceAll(' ', '_').toLowerCase();
      final String newRemoteFilePath =
          '$formattedNewName/personal_information.pdf';
      await storage.ref(newRemoteFilePath).putData(pdf);
      String newDownloadUrl =
          await storage.ref(newRemoteFilePath).getDownloadURL();
      await prefs.setString('pdf_url', newDownloadUrl);
    } catch (e) {
      return;
    }
  }

  static Future<void> deletePdfInFirebase() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? oldPdfUrl = prefs.getString('pdf_url');
    try {
      if (oldPdfUrl != null) {
        try {
          final userData = await getJsonData();
          final oldName = userData?['name'] ?? "";
          String formattedOldName = oldName.replaceAll(' ', '_').toLowerCase();
          final fullPath = "$formattedOldName/personal_information.pdf";
          final oldRef = storage.ref(fullPath);
          await oldRef.delete();
        } catch (e) {
          return;
        }
      }
    } catch (e) {
      return;
    }
  }

  static Future<void> storeUserData(Map<String, dynamic> jsonData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(jsonData);
    await prefs.setString('user_personal_information', jsonString);
  }

  static Future<void> removeUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_personal_information');
  }

  static Future<Map<String, dynamic>?> getJsonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString('user_personal_information');

    if (jsonString != null) {
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      return jsonData;
    }

    return null;
  }
}
