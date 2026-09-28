import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'login.dart';
import 'models/cart_model.dart';
import 'models/promotion_model.dart';
import 'models/order_model.dart';

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

  CartModel? _cart;
  bool _isLoadingCart = false;
  String? _cartError;

  List<PromotionModel> _promotions = [];
  bool _isLoadingPromotions = false;
  String? _promotionError;

  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;
  String? _orderError;

  int _selectedIndex = 0;
  String _userName = 'User';

  int? _addingToCartProductId;
  int? _updatingCartItemId;
  int? _removingCartItemId;
  bool _isClearingCart = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadProducts();
  }

  // ============================================================
  // LOAD USERNAME
  // ============================================================

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');

    if (!mounted) return;

    if (savedName != null && savedName.trim().isNotEmpty) {
      setState(() {
        _userName = savedName.trim();
      });
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  // LOAD PRODUCTS  

  Future<void> _loadProducts() async {
    if (!mounted) return;

    setState(() {
      _isLoadingProducts = true;
      _productError = null;
    });

    try {
      final token = await _getToken();

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

  // LOGOUT

  Future<void> _logout() async {
    if (!mounted) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');
      await prefs.remove('user_name');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Logout failed: $e',
        error: true,
      );
    }
  }

  // BOTTOM NAVIGATION

  void _onBottomNavTap(int index) {
    if (!mounted) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _loadProducts();
        break;

      case 1:
        _showAnalyticsDialog();
        break;

      case 2:
        _showOrdersDialog();
        break;

      case 3:
        _showProfileDialog();
        break;
    }
  }

  // ANALYTICS

  Future<void> _showAnalyticsDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: Colors.blue,
              ),
              SizedBox(width: 10),
              Text('Analytics'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your analytics section is ready.',
              ),
              SizedBox(height: 12),
              Text(
                'Detailed sales and performance analytics can be added here.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // PROFILE

  Future<void> _showProfileDialog() async {
    if (!mounted) return;

    await _loadUserName();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final firstLetter =
            _userName.trim().isNotEmpty
                ? _userName.trim()[0].toUpperCase()
                : 'U';

        return AlertDialog(
          title: const Text('Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Logged-in user',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // ORDERS

  Future<void> _showOrdersDialog() async {
    if (!mounted) return;

    setState(() {
      _isLoadingOrders = true;
      _orderError = null;
    });

    try {
      final token = await _getToken();

      final orders = await _apiClient.getOrders(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoadingOrders = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _orderError = e.toString();
        _isLoadingOrders = false;
      });
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        if (_isLoadingOrders) {
          return const AlertDialog(
            title: Text('Orders'),
            content: SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (_orderError != null) {
          return AlertDialog(
            title: const Text('Orders'),
            content: Text(_orderError!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        if (_orders.isEmpty) {
          return AlertDialog(
            title: const Text('Orders'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 55,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'You have no orders yet.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Orders'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _orders.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, index) {
                final order = _orders[index];

                String orderNumber =
                    'Order #${index + 1}';

                String status = 'Pending';

                String total = '';

                try {
                  final value = order.orderNumber;

                  if (value.toString().isNotEmpty) {
                    orderNumber = value.toString();
                  }
                } catch (_) {}

                try {
                  final value = order.status;

                  if 
(value.toString().isNotEmpty) {
                    status = value.toString();
                  }
                } catch (_) {}

                try {
                  final value = order.total;
                  
                  total = 'Total: ${value.toString()}';
                } catch (_) {}

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.receipt_long_outlined,
                    ),
                  ),
                  title: Text(
                    orderNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '$status'
                    '${total.isNotEmpty ? ' • $total' : ''}',
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ADD TO CART

  Future<void> _addProductToCart(
    int productId,
  ) async {
    if (_addingToCartProductId != null) return;

    if (!mounted) return;

    setState(() {
      _addingToCartProductId = productId;
    });

    try {
      final token = await _getToken();

      final cart = await _apiClient.addToCart(
        productId: productId,
        quantity: 1,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _cart = cart;
        _cartError = null;
        _addingToCartProductId = null;
      });

      _showMessage(
        'Product added to cart successfully',
      );

      await _showCartDialog();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _addingToCartProductId = null;
      });

      _showMessage(
        'Failed to add product to cart: $e',
        error: true,
      );
    }
  }

  // ============================================================
  // LOAD CART
  // ============================================================

  Future<void> _loadCart() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCart = true;
      _cartError = null;
    });

    try {
      final token = await _getToken();

      final cart = await _apiClient.getCart(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _cart = cart;
        _isLoadingCart = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cartError = e.toString();
        _isLoadingCart = false;
      });
    }
  }

  // UPDATE CART ITEM

  Future<void> _updateCartItem(
    int cartItemId,
    int quantity,
  ) async {
    if (quantity < 1) {
      await _removeCartItem(cartItemId);
      return;
    }

    if (_updatingCartItemId != null) return;

    if (!mounted) return;

    setState(() {
      _updatingCartItemId = cartItemId;
    });

    try {
      final token = await _getToken();

      final cart = await _apiClient.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _cart = cart;
        _updatingCartItemId = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _updatingCartItemId = null;
      });

      _showMessage(
        'Failed to update cart: $e',
        error: true,
      );
    }
  }

  // REMOVE CART ITEM

  Future<void> _removeCartItem(
    int cartItemId,
  ) async {
    if (_removingCartItemId != null) return;

    if (!mounted) return;

    setState(() {
      _removingCartItemId = cartItemId;
    });

    try {
      final token = await _getToken();

      final cart = await _apiClient.removeCartItem(
        cartItemId: cartItemId,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _cart = cart;
        _removingCartItemId = null;
      });

      _showMessage(
        'Item removed from cart',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _removingCartItemId = null;
      });

      _showMessage(
        'Failed to remove item: $e',
        error: true,
      );
    }
  }

  // CLEAR CART

  Future<void> _clearCart() async {
    if (_isClearingCart) return;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Clear Cart'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      _isClearingCart = true;
    });

    try {
      final token = await _getToken();

      await _apiClient.clearCart(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _cart = null;
        _isClearingCart = false;
      });

      _showMessage(
        'Cart cleared successfully',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isClearingCart = false;
      });

      _showMessage(
        'Failed to clear cart: $e',
        error: true,
      );
    }
  }

  // CART DIALOG

  Future<void> _showCartDialog() async {
    await _loadCart();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogBuildContext,
            setDialogState,
          ) {
            if (_isLoadingCart) {
              return const AlertDialog(
                title: Text('Cart'),
                content: SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (_cartError != null) {
              return AlertDialog(
                title: const Text('Cart'),
                content: Text(_cartError!),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            final cart = _cart;

            if (cart == null || cart.items.isEmpty) {
              return AlertDialog(
                title: const Text('Cart'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your cart is empty.',
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cart (${cart.totalItems})',
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 420,
                child: ListView.separated(
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(),
                  itemBuilder: (_, index) {
                    final item =
                        cart.items[index];

                    final productName =
                        item.product?.name ??
                            'Product #${item.productId}';

                    final isUpdating =
                        _updatingCartItemId ==
                            item.id;

                    final isRemoving =
                        _removingCartItemId ==
                            item.id;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding:
                              EdgeInsets.zero,

                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.green.shade50,
                            child: const Icon(
                              Icons
                                  .shopping_bag_outlined,
                              color: Colors.green,
                            ),
                          ),

                          title: Text(
                            productName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            'Price: '
                            '${item.price.toStringAsFixed(2)}\n'
                            'Subtotal: '
                            '${item.subtotal.toStringAsFixed(2)}',
                          ),

                          trailing:
                              isRemoving
                                  ? const SizedBox(
                                      width: 30,
                                      height: 30,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      tooltip:
                                          'Remove',
                                      onPressed: () async {
                                        await _removeCartItem(
                                          item.id,
                                        );

                                        if (!mounted) {
                                          return;
                                        }

                                        setDialogState(
                                          () {},
                                        );
                                      },
                                      icon:
                                          const Icon(
                                        Icons
                                            .delete_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                        ),

                        if (!isRemoving)
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              IconButton(
                                onPressed:
                                    isUpdating ||
                                            item.quantity <=
                                                1
                                        ? null
                                        : () async {
                                            await _updateCartItem(
                                              item.id,
                                              item.quantity -
                                                  1,
                                            );

                                            if (!mounted) {
                                              return;
                                            }

                                            setDialogState(
                                              () {},
                                            );
                                          },
                                icon: const Icon(
                                  Icons
                                      .remove_circle_outline,
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .grey.shade100,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              IconButton(
                                onPressed:
                                    isUpdating
                                        ? null
                                        : () async {
                                            await _updateCartItem(
                                              item.id,
                                              item.quantity +
                                                  1,
                                            );

                                            if (!mounted) {
                                              return;
                                            }

                                            setDialogState(
                                              () {},
                                            );
                                          },
                                icon: const Icon(
                                  Icons
                                      .add_circle_outline,
                                ),
                              ),

                              if (isUpdating)
                                const Padding(
                                  padding:
                                      EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child:
                                      SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                Text(
                  'Subtotal: '
                  '${cart.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(width: 5),

                TextButton.icon(
                  onPressed:
                      _isClearingCart
                          ? null
                          : () async {
                              await _clearCart();

                              if (!mounted) {
                                return;
                              }

                              setDialogState(
                                () {},
                              );
                            },
                  icon:
                      _isClearingCart
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.delete_sweep,
                              color: Colors.red,
                            ),
                  label: const Text(
                    'Clear',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // LOAD PROMOTIONS

  Future<void> _loadPromotions() async {
    if (!mounted) return;

    setState(() {
      _isLoadingPromotions = true;
      _promotionError = null;
    });

    try {
      final token = await _getToken();

      final promotions =
          await _apiClient.getPromotions(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _promotions = promotions;
        _isLoadingPromotions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _promotionError = e.toString();
        _isLoadingPromotions = false;
      });
    }
  }

  // PROMOTIONS DIALOG

  Future<void> _showPromotionsDialog() async {
    await _loadPromotions();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        if (_isLoadingPromotions) {
          return const AlertDialog(
            title: Text('Promotions'),
            content: SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (_promotionError != null) {
          return AlertDialog(
            title: const Text('Promotions'),
            content: Text(_promotionError!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        if (_promotions.isEmpty) {
          return AlertDialog(
            title: const Text('Promotions'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 55,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No active promotions available.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Promotions'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: ListView.separated(
              itemCount: _promotions.length,
              separatorBuilder: (_, _) =>
                  const Divider(),
              itemBuilder: (_, index) {
                final promotion =
                    _promotions[index];

                return ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.local_offer_outlined,
                    ),
                  ),
                  title: Text(
                    promotion.name,
                  ),
                  subtitle: Text(
                    'Code: ${promotion.code}\n'
                    'Minimum: '
                    '${promotion.minimumAmount.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    promotion.formattedValue,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
    final int id =
        int.tryParse(
          product['id']?.toString() ?? '',
        ) ??
        0;

    final String name =
        product['name']?.toString() ??
            'Unnamed Product';

    final String description =
        product['description']?.toString() ??
            '';

    final String price =
        product['price']?.toString() ?? '0';

    final int quantity =
        int.tryParse(
          product['quantity']?.toString() ?? '0',
        ) ??
        0;

    String? imageUrl =
        product['pic']?.toString();

    if (imageUrl != null &&
        imageUrl.isNotEmpty) {
      imageUrl = imageUrl.replaceFirst(
        '127.0.0.1',
        '10.0.2.2',
      );

      imageUrl = imageUrl.replaceFirst(
        'localhost',
        '10.0.2.2',
      );
    }

    final bool isAdding =
        _addingToCartProductId == id;

    final bool isOutOfStock =
        quantity <= 0;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.03,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child:
                    imageUrl != null &&
                            imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress ==
                                      null) {
                                    return child;
                                  }

                                  return _productPlaceholder();
                                },
                            errorBuilder:
                                (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return _productPlaceholder();
                                },
                          )
                        : _productPlaceholder(),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                    const SizedBox(height: 6),

                    Text(
                      'Price: $price',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      quantity > 0
                          ? 'In stock: $quantity'
                          : 'Out of stock',
                      style: TextStyle(
                        color: quantity > 0
                            ? Colors.grey
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      _viewProduct(product);
                      break;

                    case 'edit':
                      _showProductForm(
                        product: product,
                      );
                      break;

                    case 'delete':
                      _confirmDeleteProduct(
                        id,
                        name,
                      );
                      break;
                  }
                },
                itemBuilder: (context) =>
                    const [
                  PopupMenuItem<String>(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                        ),
                        SizedBox(width: 8),
                        Text('View'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                        ),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  isOutOfStock || isAdding
                      ? null
                      : () {
                          _addProductToCart(id);
                        },
              icon: isAdding
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons
                          .shopping_cart_outlined,
                    ),
              label: Text(
                isAdding
                    ? 'Adding to Cart...'
                    : isOutOfStock
                        ? 'Out of Stock'
                        : 'Add to Cart',
              ),
              style:
                  ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT PLACEHOLDER
  // ============================================================

  Widget _productPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.grey,
      ),
    );
  }

  // VIEW PRODUCT

  Future<void> _viewProduct(
    dynamic product,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? imageUrl =
            product['pic']?.toString();

        if (imageUrl != null &&
            imageUrl.isNotEmpty) {
          imageUrl = imageUrl.replaceFirst(
            '127.0.0.1',
            '10.0.2.2',
          );

          imageUrl = imageUrl.replaceFirst(
            'localhost',
            '10.0.2.2',
          );
        }

        return AlertDialog(
          title: Text(
            product['name']?.toString() ??
                'Product',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                if (imageUrl != null &&
                    imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return _productPlaceholder();
                          },
                    ),
                  ),

                const SizedBox(height: 12),

                Text(
                  'Description: '
                  '${product['description'] ?? ''}',
                ),

                const SizedBox(height: 8),

                Text(
                  'Price: ${product['price'] ?? '0'}',
                ),

                const SizedBox(height: 8),

                Text(
                  'Quantity: '
                  '${product['quantity'] ?? '0'}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
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
    if (!mounted) return;

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
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

    if (!mounted) return;

    if (confirmed == true) {
      await _deleteProduct(id);
    }
  }

  // DELETE PRODUCT

  Future<void> _deleteProduct(
    int id,
  ) async {
    try {
      final token = await _getToken();

      await _apiClient.deleteProduct(
        id: id,
        token: token,
      );

      if (!mounted) return;

      _showMessage(
        'Product deleted successfully',
      );

      await _loadProducts();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete product: $e',
        error: true,
      );
    }
  }

  // PRODUCTS DIALOG

  Future<void> _showProductsDialog() async {
    if (!mounted) return;

    final selectedProduct =
        await showDialog<dynamic>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Products'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _products.isEmpty
                ? const Center(
                    child: Text(
                      'No products available.',
                    ),
                  )
                : ListView.separated(
                    itemCount:
                        _products.length,
                    separatorBuilder:
                        (_, _) =>
                            const Divider(),
                    itemBuilder: (
                      _,
                      index,
                    ) {
                      final product =
                          _products[index];

                      return ListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        leading:
                            const CircleAvatar(
                          child: Icon(
                            Icons
                                .inventory_2_outlined,
                          ),
                        ),
                        title: Text(
                          product['name']
                                  ?.toString() ??
                              'Unnamed Product',
                        ),
                        subtitle: Text(
                          'Price: '
                          '${product['price'] ?? '0'}'
                          '  •  Stock: '
                          '${product['quantity'] ?? '0'}',
                        ),
                        onTap: () {
                          Navigator.of(
                            dialogContext,
                          ).pop(product);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop('__add__');
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Product',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (selectedProduct == '__add__') {
      await _showProductForm();
    } else if (selectedProduct != null) {
      await _viewProduct(
        selectedProduct,
      );
    }
  }

  // CREATE / UPDATE PRODUCT

  Future<void> _showProductForm({
    dynamic product,
  }) async {
    if (!mounted) return;

    final bool isEditing =
        product != null;

    final nameController =
        TextEditingController(
      text: isEditing
          ? product['name']
                  ?.toString() ??
              ''
          : '',
    );

    final descriptionController =
        TextEditingController(
      text: isEditing
          ? product['description']
                  ?.toString() ??
              ''
          : '',
    );

    final priceController =
        TextEditingController(
      text: isEditing
          ? product['price']
                  ?.toString() ??
              ''
          : '',
    );

    final quantityController =
        TextEditingController(
      text: isEditing
          ? product['quantity']
                  ?.toString() ??
              ''
          : '',
    );

    final picController =
        TextEditingController(
      text: isEditing
          ? product['pic']
                  ?.toString() ??
              ''
          : '',
    );

    final formKey =
        GlobalKey<FormState>();

    try {
      final saved =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool isSaving = false;

          return StatefulBuilder(
            builder: (
              dialogBuildContext,
              setDialogState,
            ) {
              return AlertDialog(
                title: Text(
                  isEditing
                      ? 'Edit Product'
                      : 'Add Product',
                ),
                content:
                    SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller:
                              nameController,
                          decoration:
                              const InputDecoration(
                            labelText: 'Name',
                            border:
                                OutlineInputBorder(),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Product name is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TextFormField(
                          controller:
                              descriptionController,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Description',
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TextFormField(
                          controller:
                              priceController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(
                            labelText: 'Price',
                            border:
                                OutlineInputBorder(),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Price is required';
                            }

                            if (double
                                    .tryParse(
                                  value.trim(),
                                ) ==
                                null) {
                              return 'Enter a valid price';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TextFormField(
                          controller:
                              quantityController,
                          keyboardType:
                              TextInputType
                                  .number,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Quantity',
                            border:
                                OutlineInputBorder(),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Quantity is required';
                            }

                            if (int.tryParse(
                                  value.trim(),
                                ) ==
                                null) {
                              return 'Enter a whole number';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TextFormField(
                          controller:
                              picController,
                          keyboardType:
                              TextInputType.url,
                          decoration:
                              const InputDecoration(
                            labelText:
                                'Image URL (optional)',
                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isSaving
                            ? null
                            : () {
                                Navigator.of(
                                  dialogContext,
                                ).pop(false);
                              },
                    child:
                        const Text('Cancel'),
                  ),

                  ElevatedButton.icon(
                    onPressed:
                        isSaving
                            ? null
                            : () async {
                                if (!formKey
                                    .currentState!
                                    .validate()) {
                                  return;
                                }

                                setDialogState(
                                  () {
                                    isSaving =
                                        true;
                                  },
                                );

                                try {
                                  final token =
                                      await _getToken();

                                  final name =
                                      nameController
                                          .text
                                          .trim();

                                  final description =
                                      descriptionController
                                          .text
                                          .trim();

                                  final price =
                                      double.parse(
                                    priceController
                                        .text
                                        .trim(),
                                  );

                                  final quantity =
                                      int.parse(
                                    quantityController
                                        .text
                                        .trim(),
                                  );

                                  final pic =
                                      picController
                                          .text
                                          .trim();

                                  if (isEditing) {
                                    await _apiClient
                                        .updateProduct(
                                      id: int.parse(
                                        product['id']
                                            .toString(),
                                      ),
                                      token: token,
                                      name: name,
                                      description:
                                          description,
                                      price: price,
                                      quantity:
                                          quantity,
                                      pic: pic,
                                    );
                                  } else {
                                    await _apiClient
                                        .createProduct(
                                      token: token,
                                      name: name,
                                      description:
                                          description,
                                      price: price,
                                      quantity:
                                          quantity,
                                      pic: pic,
                                    );
                                  }

                                  if (!dialogContext
                                      .mounted) {
                                    return;
                                  }

                                  Navigator.of(
                                    dialogContext,
                                  ).pop(true);
                                } catch (e) {
                                  if (!dialogContext
                                      .mounted) {
                                    return;
                                  }

                                  setDialogState(
                                    () {
                                      isSaving =
                                          false;
                                    },
                                  );

                                  ScaffoldMessenger
                                      .of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(
                                        isEditing
                                            ? 'Failed to update product: $e'
                                            : 'Failed to create product: $e',
                                      ),
                                      backgroundColor:
                                          Colors.red,
                                    ),
                                  );
                                }
                              },
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isEditing
                                ? Icons.save
                                : Icons.add,
                          ),
                    label: Text(
                      isSaving
                          ? 'Saving...'
                          : isEditing
                              ? 'Update'
                              : 'Create',
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted) return;

      if (saved == true) {
        _showMessage(
          isEditing
              ? 'Product updated successfully'
              : 'Product created successfully',
        );

        await _loadProducts();
      }
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      quantityController.dispose();
      picController.dispose();
    }
  }

  // QUICK ACTION

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
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.1,
                ),
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

  // BUILD

  @override
  Widget build(BuildContext context) {
    final firstLetter =
        _userName.trim().isNotEmpty
            ? _userName.trim()[0].toUpperCase()
            : 'U';

    return Scaffold(
      backgroundColor:
        const Color(0xFFF5F7FA),

      // APP BAR

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back $_userName 👋',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
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
            onPressed: () {
              _showMessage(
                'No new notifications',
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value ==
                  'profile') {
                _showProfileDialog();
              }
            },
            itemBuilder: (context) =>
                const [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                    ),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding:
                  const EdgeInsets.only(
                right: 15,
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor:
                    Colors.blue,
                child: Text(
                  firstLetter,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // BODY

      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // BALANCE CARD

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Colors.blue,
                      Color(0xFF1565C0),
                    ],
                    begin:
                        Alignment.topLeft,
                    end: Alignment
                        .bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue
                          .withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 15,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style:
                          TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      '\$12,450.00',
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Income',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              '\$18,200',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color:
                              Colors.white30,
                        ),
                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Expenses',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white70,
                              ),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              '\$5,750',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // QUICK ACTIONS

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons
                          .inventory_2_outlined,
                      title: 'Products',
                      color: Colors.blue,
                      onTap:
                          _showProductsDialog,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: _quickAction(
                      icon: Icons
                          .shopping_cart_outlined,
                      title: 'Cart',
                      color: Colors.green,
                      onTap:
                          _showCartDialog,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: _quickAction(
                      icon: Icons
                          .local_offer_outlined,
                      title: 'Promotions',
                      color: Colors.orange,
                      onTap:
                          _showPromotionsDialog,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // RECENT ACTIVITY

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style:
                        TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _loadProducts,
                    child:
                        const Text(
                      'Refresh',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              _buildProductsSection(),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        type:
            BottomNavigationBarType.fixed,
        selectedItemColor:
            Colors.blue,
        unselectedItemColor:
            Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            activeIcon: Icon(
              Icons.bar_chart,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            activeIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            activeIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}