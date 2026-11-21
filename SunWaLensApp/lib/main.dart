import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? imageFile;

  String resultLabel = "-";
  String confidence = "-";

  bool isLoading = false;

  final picker = ImagePicker();

  // =========================
  // GALERI
  // =========================

  Future pickGallery() async {

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
    });

    uploadImage();
  }

  // =========================
  // CAMERA
  // =========================

  Future pickCamera() async {

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      imageFile = File(picked.path);
    });

    uploadImage();
  }

  // =========================
  // SAVE HISTORY
  // =========================

  Future saveHistory(
    String label,
    String conf,
  ) async {

    final dir =
        await getApplicationDocumentsDirectory();

    final historyDir =
        Directory("${dir.path}/history");

    if (!await historyDir.exists()) {
      await historyDir.create(
        recursive: true,
      );
    }

    final timestamp =
        DateTime.now()
            .millisecondsSinceEpoch;

    // copy image

    final imagePath =
        "${historyDir.path}/$timestamp.jpg";

    await imageFile!.copy(imagePath);

    // save json

    final jsonFile = File(
      "${historyDir.path}/$timestamp.json",
    );

    await jsonFile.writeAsString(
      jsonEncode({
        "label": label,
        "confidence": conf,
        "date":
            DateTime.now().toString(),
        "image": imagePath,
      }),
    );
  }

  // =========================
  // UPLOAD
  // =========================

  Future uploadImage() async {

    if (imageFile == null) return;

    setState(() {
      isLoading = true;
    });

    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://enigmatic-overall-flagstone.ngrok-free.dev/predict',
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile!.path,
        ),
      );

      var response = await request.send();

      var responseData =
          await response.stream.bytesToString();

      var jsonData =
          jsonDecode(responseData);

      setState(() {

        resultLabel =
            jsonData["label"];

        confidence =
            jsonData["confidence"]
                .toString();
      });

      // SAVE HISTORY
      await saveHistory(
        resultLabel,
        confidence,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Upload gagal"),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {

    double screenHeight =
        MediaQuery.of(context)
            .size
            .height;

    double imageHeight =
        screenHeight * 0.4;

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "YOLOv8 Detection",
        ),

        centerTitle: true,

        actions: [

          IconButton(

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const HistoryPage(),
                ),
              );
            },

            icon: const Icon(
              Icons.history,
            ),
          ),
        ],
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

            children: [

              // IMAGE

              Container(

                height: imageHeight,

                decoration:
                    BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),

                child: imageFile == null
                    ? const Center(
                        child: Text(
                          "Belum ada gambar",
                        ),
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    16),

                        child: Image.file(
                          imageFile!,
                          fit:
                              BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(
                  height: 24),

              // RESULT

              Card(

                child: Padding(

                  padding:
                      const EdgeInsets
                          .all(16),

                  child: Column(

                    children: [

                      const Text(
                        "Hasil",
                        style:
                            TextStyle(
                          fontSize:
                              22,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height: 12),

                      Text(
                        resultLabel,
                        style:
                            const TextStyle(
                          fontSize:
                              20,
                        ),
                      ),

                      const SizedBox(
                          height: 8),

                      Text(
                        "Confidence: $confidence",
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                  height: 24),

              if (isLoading)
                const Center(
                  child:
                      CircularProgressIndicator(),
                ),

              const SizedBox(
                  height: 24),

              Row(

                children: [

                  Expanded(
                    child:
                        ElevatedButton
                            .icon(

                      onPressed:
                          pickGallery,

                      icon:
                          const Icon(
                        Icons.photo,
                      ),

                      label:
                          const Text(
                        "Galeri",
                      ),
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  Expanded(
                    child:
                        ElevatedButton
                            .icon(

                      onPressed:
                          pickCamera,

                      icon:
                          const Icon(
                        Icons.camera_alt,
                      ),

                      label:
                          const Text(
                        "Kamera",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================
// HISTORY PAGE
// =================================

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() =>
      _HistoryPageState();
}

class _HistoryPageState
    extends State<HistoryPage> {

  List<Map<String, dynamic>>
      histories = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  // =========================
  // LOAD HISTORY
  // =========================

  Future loadHistory() async {

    final dir =
        await getApplicationDocumentsDirectory();

    final historyDir =
        Directory("${dir.path}/history");

    if (!await historyDir.exists()) {
      return;
    }

    final files =
        historyDir.listSync();

    List<Map<String, dynamic>>
        loaded = [];

    for (var file in files) {

      if (file.path.endsWith(".json")) {

        final jsonData =
            jsonDecode(
          await File(file.path)
              .readAsString(),
        );

        loaded.add(jsonData);
      }
    }

    loaded = loaded.reversed.toList();

    setState(() {
      histories = loaded;
    });
  }

  // =========================
  // DELETE
  // =========================

  Future deleteHistory(
    Map<String, dynamic> item,
  ) async {

    try {

      await File(
        item["image"],
      ).delete();

      final jsonPath =
          item["image"]
              .replaceAll(
                ".jpg",
                ".json",
              );

      await File(jsonPath).delete();

      loadHistory();

    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "History",
        ),
      ),

      body: histories.isEmpty
          ? const Center(
              child: Text(
                "Belum ada history",
              ),
            )
          : ListView.builder(

              itemCount:
                  histories.length,

              itemBuilder:
                  (context, index) {

                final item =
                    histories[index];

                return Card(

                  margin:
                      const EdgeInsets
                          .all(12),

                  child: Padding(

                    padding:
                        const EdgeInsets
                            .all(12),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        ClipRRect(

                          borderRadius:
                              BorderRadius
                                  .circular(
                                      12),

                          child: Image.file(
                            File(
                              item["image"],
                            ),

                            height: 200,
                            width:
                                double.infinity,

                            fit:
                                BoxFit.cover,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          "Label: ${item["label"]}",
                        ),

                        const SizedBox(
                            height: 6),

                        Text(
                          "Confidence: ${item["confidence"]}",
                        ),

                        const SizedBox(
                            height: 6),

                        Text(
                          "Date: ${item["date"]}",
                        ),

                        const SizedBox(
                            height: 12),

                        Align(

                          alignment:
                              Alignment
                                  .centerRight,

                          child:
                              IconButton(

                            onPressed: () {
                              deleteHistory(
                                  item);
                            },

                            icon:
                                const Icon(
                              Icons.delete,
                              color:
                                  Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}