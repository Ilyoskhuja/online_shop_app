import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final List<Product> products = [];
  int currentPage = 1;
  bool isFetching = false;
  final ApiService apiService = ApiService();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isFetching) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (isFetching) return;

    setState(() {
      isFetching = true;
    });

    apiService.fetchProducts(currentPage++).then((newProducts) {
      setState(() {
        products.addAll(newProducts);
        isFetching = false;
      });
    }).catchError((error) {
      setState(() {
        isFetching = false;
      });
      // Handle errors
    });
  }

  void _addProduct() async {
    Product? newProduct = await _showAddProductDialog();
    if (newProduct != null) {
      apiService.createProduct(newProduct).then((createdProduct) {
        setState(() {
          products.add(createdProduct);
        });
      }).catchError((error) {
        // Handle errors
        print('Error creating product: $error');
      });
    }
  }

  Future<Product?> _showAddProductDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    return showDialog<Product>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Title"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Description"),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(hintText: "Image URL"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String title = titleController.text.trim();
                String description = descriptionController.text.trim();
                String imageUrl = imageUrlController.text.trim();

                if (title.isEmpty || imageUrl.isEmpty) {
                  // Show an error message or handle the validation failure
                  print('Title and Image URL are required.');
                } else {
                  Product newProduct = Product(
                    id: DateTime.now()
                        .millisecondsSinceEpoch, // Temporary ID generation logic
                    title: title,
                    description: description.isNotEmpty
                        ? description
                        : 'No description provided',
                    imageUrl: imageUrl,
                  );
                  Navigator.of(context).pop(newProduct);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editProduct(Product product) async {
    Product? updatedProduct = await _showEditProductDialog(product);
    if (updatedProduct != null) {
      apiService.updateProduct(updatedProduct.id, updatedProduct).then((_) {
        setState(() {
          int index = products.indexWhere((p) => p.id == updatedProduct!.id);
          if (index != -1) {
            products[index] = updatedProduct;
          }
        });
      }).catchError((error) {
        // Handle errors
        print('Error updating product: $error');
      });
    }
  }

  Future<Product?> _showEditProductDialog(Product product) async {
    final TextEditingController titleController =
        TextEditingController(text: product.title);
    final TextEditingController descriptionController =
        TextEditingController(text: product.description);
    final TextEditingController imageUrlController =
        TextEditingController(text: product.imageUrl);

    return showDialog<Product>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Title"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Description"),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(hintText: "Image URL"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                String title = titleController.text.trim();
                String description = descriptionController.text.trim();
                String imageUrl = imageUrlController.text.trim();

                if (title.isEmpty || imageUrl.isEmpty) {
                  // Show an error message or handle the validation failure
                  print('Title and Image URL are required.');
                } else {
                  Product updatedProduct = Product(
                    id: product.id,
                    title: title,
                    description: description.isNotEmpty
                        ? description
                        : 'No description provided',
                    imageUrl: imageUrl,
                  );
                  Navigator.of(context).pop(updatedProduct);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(int productId) {
    apiService.deleteProduct(productId).then((_) {
      setState(() {
        products.removeWhere((product) => product.id == productId);
      });
    }).catchError((error) {
      // Handle errors
      print('Error deleting product: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            leading: Image.network(product.imageUrl),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editProduct(product),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        tooltip: 'Add Product',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
