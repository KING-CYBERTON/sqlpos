import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sqlpos/Controllers/CartController.dart';
import 'package:sqlpos/mysql.dart';

import '../../Datamodels/product.dart';
import '../../constants/image_paths_constants.dart';
import '../../constants/sizes_constants.dart';
import '../../constants/text_styles_constants.dart';
import '../product_details/product_details.dart';

class ProductDashboard extends StatefulWidget {
  final String activeSubMenu;

  const ProductDashboard({
    super.key,
    required this.activeSubMenu,
  });

  @override
  ProductDashboardState createState() => ProductDashboardState();
}

class ProductDashboardState extends State<ProductDashboard> {
  int currentPage = 1;
  final int _itemsPerPage = 408;
  Product? selectedProduct;
  bool isAddingNewProduct = false;
  final CartController productController = Get.put(CartController());

  late List<Product> Productlist = [];

  Future fetchlist() async {
    final dbHelper = MySQLHelper();

    // Open the connection
    await dbHelper.openConnection();
    Productlist = await dbHelper.fetchAllProducts();
    Productlist = await dbHelper.fetchAllProducts();
    return Productlist;
  }

  @override
  void initState() async {
    // TODO: implement initState
    fetchlist();
  }

  List<Product> get _filteredAndPaginatedData {
    final filteredData = widget.activeSubMenu == 'All Products'
        ? productController.products
        : productController.products
            .where((product) => product.PCategory == widget.activeSubMenu)
            .toList();

    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return filteredData.sublist(startIndex,
        endIndex > filteredData.length ? filteredData.length : endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Products',
              style: TextStyles.getTitleStyle(context),
            ),
            SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context) / 2),
            // Breadcrumb with clickable activeSubMenu
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Home > Inventory > ',
                  style: TextStyles.getSubtitleStyle(context).copyWith(
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (selectedProduct != null) {
                      setState(() {
                        selectedProduct = null;
                        isAddingNewProduct = false;
                      });
                    }
                  },
                  child: Text(
                    widget.activeSubMenu,
                    style: TextStyles.getSubtitleStyle(context).copyWith(
                      color:
                          selectedProduct != null ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                if (selectedProduct != null)
                  Text(
                    ' > Product Details',
                    style: TextStyles.getSubtitleStyle(context).copyWith(
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (selectedProduct == null)
          OutlinedButton.icon(
            onPressed: () {
              List<Product> productLists = productController.products;
              print(productLists.length);
              setState(() {
                isAddingNewProduct = true;
                selectedProduct = null;
              });
            },
            icon: const Icon(Icons.add, color: Colors.black, size: 20),
            label: Text(
              'ADD ITEM',
              style: TextStyles.getSubtitleStyle(context),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return _buildProductGrid();

    // if (selectedProduct != null || isAddingNewProduct) {
    //   return AdminProductDetailPage(
    //     product: selectedProduct,
    //     isAddingNewProduct: isAddingNewProduct,
    //     onCancel: () {
    //       setState(() {
    //         selectedProduct = null;
    //         isAddingNewProduct = false;
    //       });
    //     },
    //     onSave: (updatedProduct) {
    //       // Implement save logic here
    //       // setState(() {
    //       //   if (isAddingNewProduct) {
    //       //     productList.add(updatedProduct);
    //       //   } else {
    //       //     int index =
    //       //         productList.indexWhere((p) => p.PId == updatedProduct.PId);
    //       //     if (index != -1) {
    //       //       productList[index] = updatedProduct;
    //       //     }
    //       //   }
    //       //   selectedProduct = null;
    //       //   isAddingNewProduct = false;
    //       // });
    //     },
    //   );
    // } else {
    //   return Obx(() => _buildProductGrid());
    // }
  }

  Widget _buildProductGrid() {
    int crossAxisCount =
        ResponsiveBreakpoints.of(context).largerThan(DESKTOP) ? 3 : 1;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio:
            ResponsiveBreakpoints.of(context).largerThan(DESKTOP) ? 1.3 : 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: Productlist.length,
      itemBuilder: (context, index) {
        final product = Productlist[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedProduct = product;
          isAddingNewProduct = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item Code:',
                            style: TextStyles.getBodyTextStyle(context),
                          ),
                          Text(
                            product.price.toString(),
                            style: TextStyles.getBodyTextStyle(context),
                          ),
                          Text(
                            'Current Price:',
                            style: TextStyles.getBodyTextStyle(context),
                          ),
                          Text(
                            product.price.toString(),
                            style: TextStyles.getBodyTextStyle(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                ],
              ),
              SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyles.getSubtitleStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                      height: ResponsiveSizes.getSizedBoxHeight(context) / 2),
                  Container(
                    padding:
                        EdgeInsets.all(ResponsiveSizes.getPadding(context)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sales',
                              style: TextStyles.getBodyTextStyle(context),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.arrow_upward,
                                    color: Colors.green, size: 12),
                                SizedBox(
                                    width: ResponsiveSizes.getPadding(context) /
                                        2),
                                Text(
                                  '${product.stockQuantity}',
                                  style: TextStyles.getBodyTextStyle(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey[300]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining Products',
                              style: TextStyles.getBodyTextStyle(context),
                            ),
                            Text(
                              '${product.stockQuantity}',
                              style:
                                  TextStyles.getBodyTextStyle(context).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                ResponsiveSizes.getSizedBoxHeight(context) / 2),
                        LinearProgressIndicator(
                          value: product.stockQuantity /
                              2000, // Assuming 2000 is the max
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.orange),
                        ),
                      ],
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
