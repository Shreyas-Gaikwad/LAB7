import 'package:flutter/material.dart';

void main() {
  runApp(RoyalFeastApp());
}

const Color royalGold = Color(0xFFFFD700);
const Color royalNavy = Color(0xFF003366);
const Color royalMaroon = Color(0xFF800000);

class RoyalFeastApp extends StatelessWidget {
  const RoyalFeastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoyalFeast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: royalNavy,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: royalNavy,
          foregroundColor: royalGold,
          titleTextStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: royalGold,
          ),
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: royalGold,
            foregroundColor: royalMaroon,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: royalNavy,
      body: Center(
        child: Text(
          "RoyalFeast",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: royalGold),
        ),
      ),
    );
  }
}

class FoodItem {
  final String name;
  final int price;
  final String image;
  FoodItem(this.name, this.price, this.image);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> orders = [];

  final List<FoodItem> menu = [
    FoodItem('Crown Burger', 180, 'assets/burger.jpg'),
    FoodItem('Imperial Pizza', 300, 'assets/pizza.jpg'),
    FoodItem('Golden Fries', 120, 'assets/fries.jpg'),
    FoodItem('Royal Latte', 90, 'assets/coffee.jpg'),
    FoodItem('Majestic Donut', 75, 'assets/donut.jpg'),
  ];

  void addToCart(FoodItem item) {
    setState(() {
      final existing = cart.firstWhere(
          (entry) => entry['item'].name == item.name,
          orElse: () => {});
      if (existing.isNotEmpty) {
        existing['quantity'] += 1;
      } else {
        cart.add({'item': item, 'quantity': 1, 'rating': 0});
      }
    });
  }

  void checkout() {
    if (cart.isNotEmpty) {
      final time = DateTime.now();
      final orderId = DateTime.now().millisecondsSinceEpoch;
      final total = cart.fold<int>(0, (int sum, entry) => sum + (entry['item'].price as int) * (entry['quantity'] as int));
      orders.add({
        'id': orderId,
        'items': List<Map<String, dynamic>>.from(cart),
        'total': total,
        'time': time
      });
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed!")));
      setState(() {});
    }
  }

  void cancelOrder(int orderId) {
    setState(() {
      orders.removeWhere((order) => order['id'] == orderId);
    });
  }

  List<Widget> get pages => [
        MenuScreen(menu: menu, onAdd: addToCart),
        CartScreen(cart: cart, onCheckout: checkout),
        OrderHistoryScreen(orders: orders, onCancel: cancelOrder),
        RoyalProfile(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("RoyalFeast")),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: royalMaroon,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class MenuScreen extends StatelessWidget {
  final List<FoodItem> menu;
  final Function(FoodItem) onAdd;
  const MenuScreen({super.key, required this.menu, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: menu.length,
        itemBuilder: (context, i) {
          final item = menu[i];
          return Card(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: Image.asset(item.image, width: 40),
              title: Text(item.name),
              subtitle: Text("₹${item.price}"),
              trailing: ElevatedButton(onPressed: () => onAdd(item), child: Text("Add")),
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final VoidCallback onCheckout;
  const CartScreen({super.key, required this.cart, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<int>(0, (int sum, entry) => sum + (entry['item'].price as int) * (entry['quantity'] as int));

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,  // Make sure the background covers the entire screen
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? Center(child: Text("Your royal cart is empty", style: TextStyle(color: royalGold)))
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) => Card(
                      margin: EdgeInsets.all(10),
                      color: Colors.amber[50],  // Item card background
                      child: ListTile(
                        title: Text(cart[i]['item'].name),
                        subtitle: Text("x${cart[i]['quantity']}"),
                        trailing: Text("₹${cart[i]['item'].price * cart[i]['quantity']}"),
                      ),
                    ),
                  ),
          ),
          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Total: ₹$total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: royalGold)),
                  SizedBox(height: 8),
                  ElevatedButton(onPressed: onCheckout, child: Text("Place Order")),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(int) onCancel;
  const OrderHistoryScreen({super.key, required this.orders, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: orders.isEmpty
          ? Center(child: Text("No royal orders yet"))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final order = orders[i];
                final items = order['items'] as List<Map<String, dynamic>>;
                final time = (order['time'] as DateTime).toLocal().toString().substring(0, 16);
                return Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.amber[50],
                  child: ExpansionTile(
                    title: Text("Order #${order['id']} - ₹${order['total']}"),
                    subtitle: Text("Placed on $time"),
                    children: [
                      ...items
                          .map((entry) => ListTile(
                                title: Text(entry['item'].name),
                                subtitle: Text("x${entry['quantity']}"),
                                trailing: Text("₹${entry['item'].price * entry['quantity']}"),
                              ))
                          .toList(),
                      TextButton(
                        onPressed: () => onCancel(order['id']),
                        child: Text("Cancel Order", style: TextStyle(color: Colors.red)),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class RoyalProfile extends StatefulWidget {
  const RoyalProfile({super.key});

  @override
  State<RoyalProfile> createState() => _RoyalProfileState();
}

class _RoyalProfileState extends State<RoyalProfile> {
  String name = "King Gourmet";
  String email = "king@royalfeast.com";
  String address = "Royal Palace, Food Street, Gourmet City";

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  bool isEditing = false;

  void toggleEdit() {
    setState(() {
      if (isEditing) {
        name = nameCtrl.text;
        email = emailCtrl.text;
        address = addressCtrl.text;
      } else {
        nameCtrl.text = name;
        emailCtrl.text = email;
        addressCtrl.text = address;
      }
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,  // Ensures the background image covers the screen
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/pfp.jpg"),
              ),
              SizedBox(height: 12),
              // Background container for profile data
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),  // Semi-transparent white background for visibility
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    isEditing
                        ? Column(
                            children: [
                              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Name")),
                              TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
                              TextField(controller: addressCtrl, decoration: InputDecoration(labelText: "Address")),
                            ],
                          )
                        : Column(
                            children: [
                              Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: royalNavy)),
                              Text(email, style: TextStyle(color: Colors.grey[700])),
                              SizedBox(height: 8),
                              Text(address, style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                    SizedBox(height: 12),
                    ElevatedButton(onPressed: toggleEdit, child: Text(isEditing ? "Save" : "Edit Profile")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
