import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/clothing_item.dart';
import '../services/api_service.dart';

class AddClothingPage
    extends StatefulWidget {

  const AddClothingPage({
    super.key,
  });

  @override
  State<AddClothingPage>
      createState() =>
          _AddClothingPageState();
}

class _AddClothingPageState
    extends State<AddClothingPage> {

  final ImagePicker picker =
      ImagePicker();

  File? selectedImage;

  String category = 'upper';

  bool processing = false;


  // ========================================================
  // PICK IMAGE
  // ========================================================

  Future<void> pickImage(
    ImageSource source,
  ) async {

    try {

      final XFile? picked =
          await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked == null) {
        return;
      }

      setState(() {
        selectedImage =
            File(picked.path);
      });

    } catch (e) {

      showMessage(
        'Could not select image: $e',
      );
    }
  }


  // ========================================================
  // PROCESS
  // ========================================================

  Future<void> processClothing()
      async {

    if (selectedImage == null) {
      return;
    }

    print('SELECTED CATEGORY: $category');

    setState(() {
      processing = true;
    });

    try {

      final ClothingItem item =
          await ApiService.processClothing(
        image: selectedImage!,
        category: category,
      );

      if (!mounted) return;

      showMessage(
        '${item.name} added to wardrobe.',
      );

      Navigator.pop(
        context,
        item,
      );

    } catch (e) {

      showMessage(
        'Could not process clothing:\n$e',
      );

    } finally {

      if (mounted) {
        setState(() {
          processing = false;
        });
      }
    }
  }


  // ========================================================
  // MESSAGE
  // ========================================================

  void showMessage(
    String message,
  ) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  // ========================================================
  // UI
  // ========================================================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Add Clothing',
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Add a clothing item',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Take a photo or choose one from your gallery.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(
              height: 24,
            ),


            // ------------------------------------------------
            // IMAGE
            // ------------------------------------------------

            Container(

              height: 330,

              width:
                  double.infinity,

              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              clipBehavior:
                  Clip.antiAlias,

              child:
                  selectedImage == null

                      ? const Center(
                          child: Icon(
                            Icons
                                .checkroom_outlined,
                            size: 80,
                            color:
                                Colors.black26,
                          ),
                        )

                      : Image.file(
                          selectedImage!,
                          fit: BoxFit.contain,
                        ),
            ),

            const SizedBox(
              height: 20,
            ),


            // ------------------------------------------------
            // GALLERY / CAMERA
            // ------------------------------------------------

            Row(

              children: [

                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        () => pickImage(
                      ImageSource
                          .gallery,
                    ),
                    icon:
                        const Icon(
                      Icons
                          .photo_library_outlined,
                    ),
                    label:
                        const Text(
                      'Gallery',
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      FilledButton.icon(
                    onPressed:
                        () => pickImage(
                      ImageSource
                          .camera,
                    ),
                    icon:
                        const Icon(
                      Icons
                          .camera_alt_outlined,
                    ),
                    label:
                        const Text(
                      'Camera',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),


            // ------------------------------------------------
            // CATEGORY
            // ------------------------------------------------

            const Text(
              'What type of clothing is this?',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            DropdownButtonFormField<
                String>(

              initialValue: category,

              decoration:
                  const InputDecoration(
                border:
                    OutlineInputBorder(),
              ),

              items: const [

                DropdownMenuItem(
                  value: 'upper',
                  child:
                      Text('Upper body'),
                ),

                DropdownMenuItem(
                  value: 'lower',
                  child:
                      Text('Lower body'),
                ),

                DropdownMenuItem(
                  value: 'full',
                  child:
                      Text('Full body / Dress'),
                ),
              ],

              onChanged:
                  (value) {

                if (value == null) {
                  return;
                }

                setState(() {
                  category =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 28,
            ),


            // ------------------------------------------------
            // PROCESS BUTTON
            // ------------------------------------------------

            SizedBox(

              width:
                  double.infinity,

              child:
                  FilledButton.icon(

                onPressed:
                    selectedImage == null ||
                            processing
                        ? null
                        : processClothing,

                icon:
                    processing

                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                            ),
                          )

                        : const Icon(
                            Icons
                                .auto_awesome,
                          ),

                label:
                    Text(
                  processing
                      ? 'Processing...'
                      : 'Process with AI',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}