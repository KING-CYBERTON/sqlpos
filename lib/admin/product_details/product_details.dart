// // ignore_for_file: unused_element

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:eccom_ui/Controllers/ProductService.dart';
// import 'package:eccom_ui/Controllers/StorageController.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// import '../../DataModels/Actualproductmodel.dart';
// import '../../Utils/constants/text_styles_constants.dart';

// class AdminProductDetailPage extends StatefulWidget {
//   final ProductModel? product;
//   final bool isAddingNewProduct;
//   final VoidCallback onCancel;
//   final Function(ProductModel) onSave;

//   const AdminProductDetailPage({
//     super.key,
//     this.product,
//     required this.isAddingNewProduct,
//     required this.onCancel,
//     required this.onSave,
//   });

//   @override
//   AdminProductDetailPageState createState() => AdminProductDetailPageState();
// }

// class AdminProductDetailPageState extends State<AdminProductDetailPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late TextEditingController _nameController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _categoryController;
//   late TextEditingController _subcategoryController;
//   late TextEditingController _brandController;
//   late TextEditingController _skuController;
//   late TextEditingController _stockController;
//   late TextEditingController _costPriceController;
//   late TextEditingController _sellingPriceController;
//   late TextEditingController _marginController;
//   late TextEditingController _itemcodeController;
//   final GlobalKey<FormState> ProductKey = GlobalKey();
//   final ProductController productController = Get.put(ProductController());
//   final Upload upload = Get.put(Upload());

//   File? _imageFile;
//   XFile? file;
//   List<XFile?> files = [];
//   List<File?> _imageFiles = [];
//   double _progress = 0.0;

//   Future<void> _pickImages() async {
//     final picker = ImagePicker();

//     // Pick multiple images
//     files = await picker.pickMultiImage();

//     if (files.isNotEmpty) {
//       setState(() {
//         _imageFiles = files.map((file) => File(file!.path)).toList();
//       });
//     }
//   }

//   // Function to pick an image using the image_picker package
//   // Future<void> _pickImage() async {
//   //   final picker = ImagePicker();

//   //   file = await picker.pickImage(source: ImageSource.gallery);

//   //   if (file != null) {
//   //     setState(() {
//   //       _imageFile = File(file!.path);
//   //     });
//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.product?.Pname ?? '');
//     _descriptionController =
//         TextEditingController(text: widget.product?.Pdescription ?? '');
//     _categoryController =
//         TextEditingController(text: widget.product?.PCategory ?? '');
//     _subcategoryController =
//         TextEditingController(text: widget.product?.Psub_category ?? '');
//     _brandController =
//         TextEditingController(text: widget.product?.Pbrand ?? '');
//     _skuController = TextEditingController(text: widget.product?.PId ?? '');
//     _stockController =
//         TextEditingController(text: widget.product?.Stocks.toString() ?? '');
//     _costPriceController =
//         TextEditingController(text: widget.product?.Pcost_P.toString() ?? '');
//     _itemcodeController =
//         TextEditingController(text: widget.product?.itemcode.toString() ?? '');
//     _sellingPriceController = TextEditingController(
//         text: widget.product?.Pselling_P.toString() ?? '');
//     _marginController =
//         TextEditingController(text: widget.product?.profit_M.toString() ?? '');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           onPressed: widget.onCancel,
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//         ),
//         title: Text(
//           widget.isAddingNewProduct ? 'Add Product' : 'Product Details',
//           style: TextStyles.getTitleStyle(context),
//         ),
//       ),
//       backgroundColor: Colors.transparent,
//       body: Form(
//         key: ProductKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   children: [
//                     _buildTextField('Name', _nameController),
//                     _buildTextField('Description', _descriptionController,
//                         maxLines: 3),
//                     _buildTextField('Category', _categoryController),
//                     _buildTextField('Sub Category', _subcategoryController),
//                     _buildTextField('Brand Name', _brandController),
//                     _buildTextField('Item code', _itemcodeController),
//                     Row(
//                       children: [
//                         Expanded(child: _buildTextField('SKU', _skuController)),
//                         const SizedBox(width: 16),
//                         Expanded(
//                             child: _buildTextField(
//                                 'Stock Quantity', _stockController)),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: _buildTextField(
//                                 'Cost Price', _costPriceController)),
//                         const SizedBox(width: 16),
//                         Expanded(
//                             child:
//                                 _buildTextField('Margin', _marginController)),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: _buildTextField(
//                                 'Selling Price', _sellingPriceController)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   children: [
//                     _buildProductsGallery(),
//                     const SizedBox(height: 16),
//                     _buildActionButtons(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller,
//       {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         style: TextStyles.getSubtitleStyle(context),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter product $label';
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         maxLines: maxLines,
//       ),
//     );
//   }

//   Widget _buildProductsGallery() {
//     return Column(
//       children: [
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 4,
//               mainAxisSpacing: 4,
//             ),
//             itemCount: _imageFiles.length + 1, // Add 1 for the "Add Image" item
//             itemBuilder: (context, index) {
//               if (index < _imageFiles.length) {
//                 // Show existing images
//                 return kIsWeb
//                     ? Image.network(_imageFiles[index]!.path)
//                     : Image.file(_imageFiles[index]!);
//               } else {
//                 // Show "Add Image" button
//                 return GestureDetector(
//                   onTap: _pickImages,
//                   child: Container(
//                     color: Colors.grey[200],
//                     child: const Center(
//                       child: Icon(
//                         Icons.add_a_photo,
//                         size: 50,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//         // Show progress bar while uploading
//         if (_progress > 0 && _progress < 1)
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: LinearProgressIndicator(value: _progress),
//           ),

//         // Show "Upload Complete" when done
//         if (_progress == 1 && files.length == _imageFiles.length)
//           Text(
//             'Upload Complete!',
//             style: TextStyles.getSubtitleStyle(context),
//           ),
//         const SizedBox(height: 16),

//         ...List.generate(
//             widget.product!.Image.length,
//             (index) => widget.product!.Image.isEmpty
//                 ? _buildAddThumbnailItem()
//                 : _buildThumbnailItem(
//                     image: widget.product!.Image[index], imagenum: index)),
//       ],
//     );
//   }

//   Widget _buildProductGallery() {
//     return widget.product == null
//         ? Column(
//             children: [
//               Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: _imageFile != null
//                     ? kIsWeb
//                         ? Image.network(_imageFile!.path)
//                         : Image.file(_imageFile!)
//                     : Center(
//                         child: IconButton(
//                         onPressed: () {
//                           _pickImages();
//                         },
//                         icon: const Icon(Icons.add_photo_alternate,
//                             size: 50, color: Colors.grey),
//                       )),
//               ),
//             ],
//           )
//         : Obx(() => Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildAddThumbnailItem(),
//                 const SizedBox(height: 16),
//                 ...List.generate(
//                     widget.product!.Image.length,
//                     (index) => widget.product!.Image.isEmpty
//                         ? _buildAddThumbnailItem()
//                         : _buildThumbnailItem(
//                             image: widget.product!.Image[index],
//                             imagenum: index)),
//               ],
//             ));
//   }

//   Widget _buildThumbnailItem({required imagenum, required String image}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             color: Colors.grey[300],
//             child: widget.product!.Image.isEmpty
//                 ? const Icon(Icons.add_photo_alternate,
//                     size: 50, color: Colors.grey)
//                 : Image.network(
//                     image,
//                     fit: BoxFit.contain,
//                   ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 widget.product!.Image.isEmpty
//                     ? Text(
//                         "Add Item",
//                         style: TextStyles.getSubtitleStyle(context),
//                       )
//                     : Text(
//                         "Image $imagenum",
//                         style: TextStyles.getSubtitleStyle(context),
//                       ),
//                 const SizedBox(height: 4),
//                 const LinearProgressIndicator(value: 1),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           GestureDetector(
//               onTap: () async {
//                 DocumentReference docRef =
//                     _firestore.collection("Inventory").doc(widget.product!.PId);
//                 // Add new images to the existing array using arrayUnion
//                 await docRef.update({
//                   'Image': FieldValue.arrayRemove(widget
//                       .product!.Image), // Adds new images without replacing
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       'Product updated successfully, images added!',
//                       style: TextStyles.getBodyTextStyle(context),
//                     ),
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               },
//               child: const Icon(Icons.delete, color: Colors.red)),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddThumbnailItem() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             color: Colors.grey[300],
//             child: const Icon(Icons.add_photo_alternate,
//                 size: 50, color: Colors.black),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'add image',
//                   style: TextStyles.getSubtitleStyle(context),
//                 ),
//                 const SizedBox(height: 4),
//                 // Show progress bar while uploading
//                 if (_progress > 0 && _progress < 1)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: LinearProgressIndicator(value: _progress),
//                   ),

//                 // Show "Upload Complete" when done
//                 if (_progress == 1)
//                   Text(
//                     'Upload Complete!',
//                     style: TextStyles.getSubtitleStyle(context),
//                   ),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           const Icon(Icons.check_circle, color: Colors.blue),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             if (ProductKey.currentState?.validate() ?? false) {
//               _updateProducts();
//             }
//           }, // Call the save product method
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: Text(
//             widget.isAddingNewProduct ? 'ADD ITEM' : 'UPDATE',
//             style: TextStyles.getSubtitleStyle(context)
//                 .copyWith(color: Colors.white),
//           ),
//         ),
//         const SizedBox(width: 16),
//         if (!widget.isAddingNewProduct)
//           ElevatedButton(
//             onPressed: () {
//               // Implement delete logic
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//             child: Text(
//               'DELETE',
//               style: TextStyles.getSubtitleStyle(context)
//                   .copyWith(color: Colors.white),
//             ),
//           ),
//         const SizedBox(width: 16),
//         OutlinedButton(
//           onPressed: widget.onCancel,
//           style: OutlinedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//           ),
//           child: Text('CANCEL', style: TextStyles.getSubtitleStyle(context)),
//         ),
//       ],
//     );
//   }

//   void _updateProducts() async {
//     final newProduct = ProductModel(
//       PId: widget.product!.PId, // SKU as product ID
//       Pname: _nameController.text.trim(),
//       Pdescription: _descriptionController.text.trim(),
//       Pbrand: _brandController.text.trim(),
//       Psub_category: _subcategoryController.text.trim(),
//       PCategory: _categoryController.text.trim(),
//       Pselling_P: double.tryParse(_sellingPriceController.text.trim()) ?? 0.0,
//       Pcost_P: double.tryParse(_costPriceController.text.trim()) ?? 0.0,
//       profit_M: double.tryParse(_marginController.text.trim()) ?? 0.0,
//       Stocks: int.tryParse(_stockController.text.trim()) ?? 0,
//       sales: widget.product!.sales, // Assuming new products have no sales
//       DateCreated: widget.product!.DateCreated,
//       Image: [], // Initialize with empty list for images
//       sku: _skuController.text.trim(),
//       itemcode: int.tryParse(_itemcodeController.text.trim()) ?? 0,
//     );

//     // Upload images and get their URLs
//     List<String> imageUrls = [];
//     for (var file in files) {
//       await upload.uploadimage(
//         file: file,
//         context: context,
//         onProgress: (progress) {
//           setState(() {
//             _progress = progress;
//           });
//         },
//       );
//       //   Implement this function
//       imageUrls.add(upload.imageUrl.value);
//     }

//     newProduct.Image = imageUrls; // Save the image URLs in the product object

//     productController.updateProduct(newProduct, context);
//   }

//   void _saveProducts(ProductModel product) async {
//     final newProduct = ProductModel(
//       PId: "", // SKU as product ID
//       Pname: _nameController.text.trim(),
//       Pdescription: _descriptionController.text.trim(),
//       Pbrand: _brandController.text.trim(),
//       Psub_category: _subcategoryController.text.trim(),
//       PCategory: _categoryController.text.trim(),
//       Pselling_P: double.tryParse(_sellingPriceController.text.trim()) ?? 0.0,
//       Pcost_P: double.tryParse(_costPriceController.text.trim()) ?? 0.0,
//       profit_M: double.tryParse(_marginController.text.trim()) ?? 0.0,
//       Stocks: int.tryParse(_stockController.text.trim()) ?? 0,
//       sales: 0, // Assuming new products have no sales
//       DateCreated: DateTime.now(),
//       Image: [], // Initialize with empty list for images
//       sku: _skuController.text.trim(),
//       itemcode: int.tryParse(_itemcodeController.text.trim()) ?? 0,
//     );

//     // Upload images and get their URLs
//     List<String> imageUrls = [];
//     for (var file in files) {
//       await upload.uploadimage(
//         file: file,
//         context: context,
//         onProgress: (progress) {
//           setState(() {
//             _progress = progress;
//           });
//         },
//       );
//       //   Implement this function
//       imageUrls.add(upload.imageUrl.value);
//     }

//     newProduct.Image = imageUrls; // Save the image URLs in the product object

//     productController.addProduct(newProduct, context);

//     setState(() {
//       // Clear the form fields
//       _nameController.clear();
//       _descriptionController.clear();
//       _brandController.clear();
//       _subcategoryController.clear();
//       _categoryController.clear();
//       _sellingPriceController.clear();
//       _costPriceController.clear();
//       _marginController.clear();
//       _stockController.clear();
//       _skuController.clear();
//       _itemcodeController.clear();

//       // Optionally, clear the image files list if needed
//       files.clear();
//       _imageFiles.clear();
//     });
//   }

//   Future<String?> uploadImageToFirebase({
//     required XFile image,
//   }) async {
//     try {
//       // Create a reference to the storage location
//       final storageRef =
//           FirebaseStorage.instance.ref().child('imagestestt/${image.name}');

//       // Upload the file to Firebase Storage
//       if (kIsWeb) {
//         // For web, upload the file as a Blob
//         final byteData = await image.readAsBytes();
//         await storageRef.putData(byteData);
//       } else {
//         // For mobile, use the file directly
//         await storageRef.putFile(File(image.path));
//       }

//       // Get the download URL
//       String downloadUrl = await storageRef.getDownloadURL();
//       print(
//         "Image uploaded successfully: $downloadUrl",
//       );
//       return downloadUrl;

//       // Use the download URL as needed
//     } catch (e) {
//       print("Error uploading image: $e");
//     }
//     return null;
//   }

//   void _saveProduct() async {
//     await upload.uploadimage(
//       file: file,
//       context: context,
//       onProgress: (progress) {
//         setState(() {
//           _progress = progress;
//         });
//       },
//     );

//     final newProduct = ProductModel(
//       PId: '', // SKU as product ID
//       Pname: _nameController.text.trim(),
//       Pdescription: _descriptionController.text.trim(),
//       Pbrand: _brandController.text.trim(),
//       Psub_category: _subcategoryController.text.trim(),
//       PCategory: _categoryController.text.trim(),
//       Pselling_P: double.tryParse(
//             _sellingPriceController.text.trim(),
//           ) ??
//           0.0,
//       Pcost_P: double.tryParse(
//             _costPriceController.text.trim(),
//           ) ??
//           0.0,
//       profit_M: double.tryParse(
//             _marginController.text.trim(),
//           ) ??
//           0.0,
//       Stocks: int.tryParse(
//             _stockController.text.trim(),
//           ) ??
//           0,
//       sales: 0, // Assuming new products have no sales
//       DateCreated: DateTime.now(),
//       Image: [upload.imageUrl.value],
//       sku: _skuController.text.trim(),

//       itemcode: int.tryParse(
//             _itemcodeController.text.trim(),
//           ) ??
//           0, // Handle image uploads separately
//     );

//     productController.addProduct(newProduct, context);
//     //  widget.onSave(newProduct.toJson()); // Callback to pass the product back
//   }

//   // @override
//   // void dispose() {
//   //   _nameController.dispose();
//   //   _descriptionController.dispose();
//   //   _categoryController.dispose();
//   //   _brandController.dispose();
//   //   _skuController.dispose();
//   //   _stockController.dispose();
//   //   _costPriceController.dispose();
//   //   _sellingPriceController.dispose();
//   //   _marginController.dispose();
//   //   super.dispose();
//   // }
// }
