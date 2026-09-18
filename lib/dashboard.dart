import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiClient _apiClient = ApiClient();

  List<dynamic> _products = [];

  bool _isLoadingProducts = true;

  String? _productError;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

 // LOAD PRODUCTS FROM LARAVEL

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoadingProducts = true;
        _productError = null;
      });

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final products = await _apiClient.getProducts(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _productError = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  // BOTTOM NAVIGATION
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back 👋',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 3),

            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),

      // BODY
      body: RefreshIndicator(
        onRefresh: _loadProducts,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              // BALANCE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Color(0xFF1565C0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '\$12,450.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Income',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              '\$18,200',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white30,
                        ),

                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Expenses',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              '\$5,750',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              // QUICK ACTIONS
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [

                  Expanded(
                    child: _quickAction(
                      icon: Icons.add_circle_outline,
                      title: 'Add Money',
                      color: Colors.green,
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.send_outlined,
                      title: 'Send',
                      color: Colors.blue,
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _quickAction(
                      icon: Icons.receipt_long_outlined,
                      title: 'Bills',
                      color: Colors.orange,
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
 
              // PRODUCTS / RECENT ACTIVITY
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: _loadProducts,
                    child: const Text('Refresh'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _buildProductsSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // PRODUCTS SECTION
  Widget _buildProductsSection() {
    if (_isLoadingProducts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_productError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          children: [

            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 40,
            ),

            const SizedBox(height: 10),

            Text(
              _productError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),

        child: const Column(
          children: [

            Icon(
              Icons.inventory_2_outlined,
              color: Colors.grey,
              size: 45,
            ),

            SizedBox(height: 10),

            Text(
              'No products found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _products.map((product) {
        return _productCard(product);
      }).toList(),
    );
  }

  // PRODUCT CARD
  Widget _productCard(dynamic product) {
    final int id = product['id'];

    final String name =
        product['name']?.toString() ?? 'Unnamed Product';

    final String description =
        product['description']?.toString() ?? '';

    final String price =
        product['price']?.toString() ?? '0';

    final String quantity =
        product['quantity']?.toString() ?? '0';

    String? imageUrl =
        product['pic']?.toString();

    if (imageUrl != null &&
        imageUrl.isNotEmpty) {
      imageUrl = imageUrl.replaceFirst(
        '127.0.0.1',
        '10.0.2.2',
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [

          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: imageUrl != null &&
                    imageUrl.isNotEmpty

                ? Image.network(
                    imageUrl,

                    width: 65,
                    height: 65,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (context, error, stackTrace) {
                      return _productPlaceholder();
                    },
                  )

                : _productPlaceholder(),
          ),

          const SizedBox(width: 12),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Price: $price',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  'Quantity: $quantity',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // MENU
          PopupMenuButton<String>(
            onSelected: (value) {

              if (value == 'view') {
                _viewProduct(product);
              }

              if (value == 'delete') {
                _confirmDeleteProduct(
                  id,
                  name,
                );
              }
            },

            itemBuilder: (context) => const [

              PopupMenuItem(
                value: 'view',
                child: Text('View'),
              ),

              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PRODUCT PLACEHOLDER
  Widget _productPlaceholder() {
    return Container(
      width: 65,
      height: 65,

      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),

      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey,
      ),
    );
  }

  // VIEW PRODUCT
  void _viewProduct(dynamic product) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(
            product['name'] ?? 'Product',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                'Description: '
                '${product['description'] ?? ''}',
              ),

              const SizedBox(height: 8),

              Text(
                'Price: ${product['price']}',
              ),

              const SizedBox(height: 8),

              Text(
                'Quantity: ${product['quantity']}',
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // CONFIRM DELETE
  Future<void> _confirmDeleteProduct(
    int id,
    String name,
  ) async {

    final confirmed =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product',
          ),

          content: Text(
            'Are you sure you want to delete "$name"?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteProduct(id);
    }
  }

  // DELETE PRODUCT
  Future<void> _deleteProduct(int id) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString('token');

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Authentication token not found.',
        );
      }

      await _apiClient.deleteProduct(
        id: id,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Product deleted successfully',
          ),
        ),
      );

      await _loadProducts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete product: $e',
          ),
        ),
      );
    }
  }

  // QUICK ACTION WIDGET
  Widget _quickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          children: [

            Container(
              padding:
                  const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color:
                    color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: color,
                size: 25,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,

              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}