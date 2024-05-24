import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_test1/models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();
  final Dio dio = Dio();
  List<Product> products = [];
  int totalProducts = 0; // Updated to 0 initially
  bool isLoading = false;
  bool hasMoreData = true; // To track if more data is available

  @override
  void initState() {
    super.initState();
    getProducts();
    scrollController.addListener(loadMoreData);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Our Products",
            style: TextStyle(
              color: Colors.black38,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: isLoading && products.isEmpty
          ? const Center(
              child: SpinKitThreeBounce(
                color: Colors.purple,
                size: 40,
              ),
            )
          : products.isEmpty && !isLoading
              ? const Center(child: Text('No products available'))
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: scrollController,
                  itemCount: products.length + (hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == products.length) {
                      // Show loading indicator at the end
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: SpinKitThreeBounce(
                          color: Colors.purple,
                          size: 40,
                        ),
                      );
                    }
                    final product = products[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: Text(product.id.toString()),
                          title: Text(product.title ?? "No Title"),
                          subtitle: Text("\$${product.price.toString()}"),
                          trailing: product.thumbnail != null
                              ? Image.network(
                                  product.thumbnail!,
                                  width: 150,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  void loadMoreData() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMoreData) {
      getProducts();
    }
  }

  Future<void> getProducts() async {
    if (!hasMoreData) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await dio.get(
          'https://dummyjson.com/products?limit=15&skip=${products.length}&select=title,price,thumbnail');
      final List data = response.data["products"];
      print("API Response: ${response.data}"); // Debug statement
      if (data.isNotEmpty) {
        final List<Product> newProducts =
            data.map((p) => Product.fromJson(p)).toList();
        setState(() {
          isLoading = false;
          if (newProducts.isEmpty) {
            hasMoreData = false;
          } else {
            products.addAll(newProducts);
            totalProducts = response.data["total"];
            print(
                "Total products fetched: ${products.length}"); // Debug statement
          }
        });
      } else {
        setState(() {
          isLoading = false;
          hasMoreData = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching products: $e');
    }
  }
}
