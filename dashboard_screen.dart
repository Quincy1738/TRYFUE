import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'analytics_page.dart';
import 'settings_page.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<double> last30DaysTotalRevenue = List.filled(30, 0.0);
  List<double> last12MonthsTotalRevenue = List.filled(12, 0.0);

  double dieselRevenue = 0.0;
  double petrolRevenue = 0.0;

  double dieselLiters = 0.0;
  double dieselPrice = 0.0;
  double petrolLiters = 0.0;
  double petrolPrice = 0.0;

  double totalRevenue = 0.0;

  double maxDieselCapacity = 10000;
  double maxPetrolCapacity = 10000;
  double lowThresholdPercent = 0.25;

  final TextEditingController _dieselLitersController = TextEditingController();
  final TextEditingController _dieselPriceController = TextEditingController();
  final TextEditingController _petrolLitersController = TextEditingController();
  final TextEditingController _petrolPriceController = TextEditingController();

  Timer? _reductionTimer; // Timer for periodic reduction

  // List to store last 7 days total revenue (including today)
  List<double> last7DaysTotalRevenue = List.filled(7, 0.0);

  int todayIndex = 6; // Index for today's sales in the last7DaysTotalRevenue list

  @override
  void initState() {
    super.initState();
    _startAutoReduction();
  }

  void _startAutoReduction() {
    _reductionTimer = Timer.periodic(Duration(seconds: 20), (_) {
      setState(() {
        int dieselReduction = 5 + Random().nextInt(46); // 5–50
        int petrolReduction = 5 + Random().nextInt(46); // 5–50

        if (dieselReduction + petrolReduction > 100) {
          int excess = (dieselReduction + petrolReduction) - 100;
          if (dieselReduction > petrolReduction) {
            dieselReduction = (dieselReduction - excess).clamp(0, dieselReduction);
          } else {
            petrolReduction = (petrolReduction - excess).clamp(0, petrolReduction);
          }
        }

        dieselLiters = (dieselLiters - dieselReduction).clamp(0, maxDieselCapacity);
        petrolLiters = (petrolLiters - petrolReduction).clamp(0, maxPetrolCapacity);
      });
    });
  }

  @override
  void dispose() {
    _reductionTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // Helper to add diesel revenue and update today's total sales
  void _addDieselRevenue(double liters, double price) {
    double revenue = liters * price;
    setState(() {
      dieselRevenue += revenue;
      totalRevenue += revenue;
      last7DaysTotalRevenue[todayIndex] += revenue;
    });
  }

  // Helper to add petrol revenue and update today's total sales
  void _addPetrolRevenue(double liters, double price) {
    double revenue = liters * price;
    setState(() {
      petrolRevenue += revenue;
      totalRevenue += revenue;
      last7DaysTotalRevenue[todayIndex] += revenue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardContent(),
          AnalyticsPage(
            totalRevenue: totalRevenue,
            last7DaysRevenue: last7DaysTotalRevenue,
            last30DaysRevenue: last30DaysTotalRevenue,
            last12MonthsRevenue: last12MonthsTotalRevenue,
          ),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Fuel Management",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTankStatus("Diesel", dieselLiters, maxDieselCapacity, Icons.local_gas_station),
                _buildTankStatus("Petrol", petrolLiters, maxPetrolCapacity, Icons.local_gas_station_outlined),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildInputSection(),
        SizedBox(height: 20),
        _buildAnalyticsCard(),
        SizedBox(height: 20),
        _buildAlertSection(),
      ]),
    );
  }

  Widget _buildTankStatus(String label, double liters, double maxLiters, IconData icon) {
    double percent = liters / maxLiters;
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Row(children: [
                Icon(icon, size: 20),
                SizedBox(width: 6),
                Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
              SizedBox(height: 8),
              Text("${liters.toStringAsFixed(0)} L"),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: percent.clamp(0, 1),
                backgroundColor: Colors.grey[300]!,
                progressColor: percent < lowThresholdPercent ? Colors.red : Colors.green,
              ),
              SizedBox(height: 4),
              Text("${(percent * 100).toStringAsFixed(0)}% Capacity", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Update Tank Info", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _buildFuelInput(
          "Diesel",
          _dieselLitersController,
          _dieselPriceController,
              () {
            double inputLiters = double.tryParse(_dieselLitersController.text) ?? 0.0;
            double inputPrice = double.tryParse(_dieselPriceController.text) ?? dieselPrice;

            if (dieselLiters + inputLiters > maxDieselCapacity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Diesel tank is full. Cannot exceed 10,000L.")),
              );
            } else {
              setState(() {
                dieselLiters += inputLiters;
                dieselPrice = inputPrice;
                _addDieselRevenue(inputLiters, inputPrice);
                _dieselLitersController.clear();
                _dieselPriceController.clear();
              });
            }
          },
        ),
        SizedBox(height: 10),
        _buildFuelInput(
          "Petrol",
          _petrolLitersController,
          _petrolPriceController,
              () {
            double inputLiters = double.tryParse(_petrolLitersController.text) ?? 0.0;
            double inputPrice = double.tryParse(_petrolPriceController.text) ?? petrolPrice;

            if (petrolLiters + inputLiters > maxPetrolCapacity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Petrol tank is full. Cannot exceed 10,000L.")),
              );
            } else {
              setState(() {
                petrolLiters += inputLiters;
                petrolPrice = inputPrice;
                _addPetrolRevenue(inputLiters, inputPrice);
                _petrolLitersController.clear();
                _petrolPriceController.clear();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildFuelInput(String label, TextEditingController literCtrl, TextEditingController priceCtrl, VoidCallback onEnter) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$label Input", style: TextStyle(fontWeight: FontWeight.w500)),
            TextField(
              controller: literCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Liters Available"),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Price per Liter"),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text("Enter"),
              onPressed: onEnter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(),
            ListTile(
              title: Text("Diesel Sales"),
              trailing: Text("₱${dieselRevenue.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: Text("Petrol Sales"),
              trailing: Text("₱${petrolRevenue.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Divider(),
            ListTile(
              title: Text("Total Sales"),
              trailing: Text(
                "₱${totalRevenue.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection() {
    List<Widget> alerts = [];

    if ((dieselLiters / maxDieselCapacity) < lowThresholdPercent) {
      alerts.add(_buildAlertTile("Low Fuel Alert", "Diesel tank below 25%", Icons.warning_amber));
    }

    if ((petrolLiters / maxPetrolCapacity) < lowThresholdPercent) {
      alerts.add(_buildAlertTile("Low Fuel Alert", "Petrol tank below 25%", Icons.warning_amber));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Alerts", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        if (alerts.isNotEmpty)
          ...alerts
        else
          _buildAlertTile("No Alerts", "Fuel levels are normal", Icons.check_circle_outline),
      ],
    );
  }

  Widget _buildAlertTile(String title, String subtitle, IconData icon) {
    return Card(
      color: title.contains("Low") ? Colors.red.shade50 : Colors.green.shade50,
      child: ListTile(
        leading: Icon(icon, color: title.contains("Low") ? Colors.red : Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
