// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:typed_data';

// import 'package:bb_ble_task_1/widgets/common_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// import '../services/common_services.dart';

// class PdfViewScreen extends StatefulWidget {
//   final Uint8List file;
//   const PdfViewScreen({
//     Key? key,
//     required this.file,
//   }) : super(key: key);

//   @override
//   State<PdfViewScreen> createState() => _PdfViewScreenState();
// }

// class _PdfViewScreenState extends State<PdfViewScreen> {
//   late TextEditingController nameOfUser;
//   bool loading = false;

//   @override
//   void initState() {
//     super.initState();
//     nameOfUser = TextEditingController();
//   }

//   @override
//   void dispose() {
//     nameOfUser.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: PDFView(
//                 // filePath: path,
//                 pdfData: widget.file,
//                 enableSwipe: true,
//                 swipeHorizontal: true,
//                 autoSpacing: false,
//                 pageFling: false,
//                 onRender: (_pages) {
//                   setState(() {
//                     // pages = _pages;
//                     // isReady = true;
//                   });
//                 },
//                 onError: (error) {
//                   print(error.toString());
//                 },
//                 onPageError: (page, error) {
//                   print('$page: ${error.toString()}');
//                 },
//                 onViewCreated: (PDFViewController pdfViewController) {
//                   // _controller.complete(pdfViewController);
//                 },
//                 // onPageChanged: (int page, int total) {
//                 //   print('page change: $page/$total');
//                 // },
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: CommonTextfield(
//                 hintText: "Enter your name",
//                 controller: nameOfUser,
//               ),
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: () async {
               
//               },
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 10),
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.symmetric(vertical: 18),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.black,
//                 ),
//                 child: (loading)
//                     ? const Center(
//                         child: SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                           ),
//                         ),
//                       )
//                     : const Text(
//                         "Save To Server",
//                         style: TextStyle(color: Colors.white),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
