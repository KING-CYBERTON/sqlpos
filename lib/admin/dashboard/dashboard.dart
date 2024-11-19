import '/constants/colors_n_styles_constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';


import '/constants/image_paths_constants.dart';
import '/constants/sizes_constants.dart';
import '/constants/text_styles_constants.dart';
import '../all_products/all_products.dart';
import '../order_list/order_list.dart';
import '../transactions/transactions.dart';
import '../users/users.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  bool isDrawerOpen = true;
  String activeTab = 'Dashboard';
  String activeSubTab = 'All Products'; // Add this line

  void _onTabSelected(String selectedTab) {
    setState(() {
      if (selectedTab.contains('/')) {
        // This is a subtab selection
        final parts = selectedTab.split('/');
        activeTab = parts[0];
        activeSubTab = parts[1];
      } else {
        activeTab = selectedTab;
      }
    });
  }

  Widget _buildContent(BuildContext context) {
    switch (activeTab) {
      case 'Dashboard':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardDateRangePickerPopup(),
                const SizedBox(height: 16),
                const _StatisticsGrid(),
                const SizedBox(height: 24),
                ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SalesGraph(),
                          const SizedBox(height: 24),
                          const _BestSellers(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SalesGraph(),
                          ),
                          const SizedBox(width: 24),
                          const Expanded(
                            child: _BestSellers(),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                const _RecentOrders(),
              ],
            ),
          ),
        );
      case 'All Products':
        return ProductDashboard(activeSubMenu: activeSubTab);
      case 'Sales':
        return const OrderList();
      // case 'Transactions':
      //   return const Transactions();
      case 'Users List':
        return const UsersList();
      default:
        return Center(
            child: Text(
          'Select a tab from the drawer',
          style: TextStyles.getBodyTextStyle(context),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
          ? AdminDrawer(
              isDrawerOpen: isDrawerOpen,
              onTabSelected: _onTabSelected,
              activeTab: activeTab,
              activeSubTab: activeSubTab, // Add this line
            )
          : const SizedBox.shrink(),
      backgroundColor:
          AppColorsnStylesConstants.primaryColorLight.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              padding: const EdgeInsets.all(2),
              child: PopupMenuButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ADMIN',
                        style: TextStyles.getTitleStyle(context),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                      child: Text(
                    'Profile',
                    style: TextStyles.getBodyTextStyle(context),
                  )),
                  PopupMenuItem(
                      child: Text(
                    'Settings',
                    style: TextStyles.getBodyTextStyle(context),
                  )),
                  PopupMenuItem(
                      child: Text(
                    'Logout',
                    style: TextStyles.getBodyTextStyle(context),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
              ? const SizedBox.shrink()
              : AdminDrawer(
                  isDrawerOpen: isDrawerOpen,
                  onTabSelected: _onTabSelected,
                  activeTab: activeTab,
                  activeSubTab: activeSubTab, // Add this line
                ),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }
}

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({
    super.key,
    required this.isDrawerOpen,
    required this.activeTab,
    required this.activeSubTab,
    required this.onTabSelected,
  });

  final bool isDrawerOpen;
  final String activeTab;
  final String activeSubTab;
  final ValueChanged<String> onTabSelected;

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  bool isProductsExpanded = false;

  final List<String> productCategories = [
    'All Products',
  ];

  @override
  void didUpdateWidget(AdminDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Close submenu if a different main tab is selected
    if (widget.activeTab != 'All Products' && isProductsExpanded) {
      setState(() {
        isProductsExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isDrawerOpen ? 250 : 0,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
         
            _buildDrawerItem('Dashboard', Icons.dashboard),
            _buildExpandableDrawerItem(
              'All Products',
              Icons.list,
              isProductsExpanded,
              productCategories,
            ),
            _buildDrawerItem('Sales', Icons.shopping_cart),
            _buildDrawerItem('Transactions', Icons.money),
            _buildDrawerItem('Users List', Icons.people),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String tabName, IconData icon) {
    final isSelected = widget.activeTab == tabName;
    return Container(
      color: isSelected
          ? AppColorsnStylesConstants.primaryColorLight
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : AppColorsnStylesConstants.primaryColorLight,
        ),
        title: Text(
          tabName,
          style: TextStyles.getBodyTextStyle(context).copyWith(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
        onTap: () => widget.onTabSelected(tabName),
      ),
    );
  }

  Widget _buildExpandableDrawerItem(
    String tabName,
    IconData icon,
    bool isExpanded,
    List<String> subItems,
  ) {
    final isSelected = widget.activeTab == tabName;
    return Column(
      children: [
        Container(
          color: isSelected
              ? AppColorsnStylesConstants.primaryColorLight
              : Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppColorsnStylesConstants.primaryColorLight,
            ),
            title: Text(
              tabName,
              style: TextStyles.getBodyTextStyle(context).copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: isSelected
                  ? Colors.white
                  : AppColorsnStylesConstants.primaryColorLight,
            ),
            onTap: () {
              setState(() {
                isProductsExpanded = !isProductsExpanded;
              });
              widget.onTabSelected(tabName);
            },
          ),
        ),
        if (isExpanded)
          Column(
            children: subItems.map((subItem) {
              final isSubItemSelected = widget.activeSubTab == subItem;
              return Container(
                color: isSubItemSelected
                    ? AppColorsnStylesConstants.primaryColorLight
                        .withOpacity(0.1)
                    : Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 50.0),
                  title: Text(
                    subItem,
                    style: TextStyles.getBodyTextStyle(context).copyWith(
                      color: isSubItemSelected
                          ? AppColorsnStylesConstants.primaryColorLight
                          : Colors.black,
                    ),
                  ),
                  onTap: () {
                    widget.onTabSelected('$tabName/$subItem');
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class DashboardDateRangePickerPopup extends StatefulWidget {
  const DashboardDateRangePickerPopup({super.key});

  @override
  DashboardDateRangePickerPopupState createState() =>
      DashboardDateRangePickerPopupState();
}

class DashboardDateRangePickerPopupState
    extends State<DashboardDateRangePickerPopup> {
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _setDefaultDateRangeToThisWeek();
  }

  void _setDefaultDateRangeToThisWeek() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    selectedDateRange =
        DateTimeRange(start: firstDayOfWeek, end: lastDayOfWeek);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyles.getBodyTextStyle(context)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Home > Dashboard',
              style: TextStyles.getBodyTextStyle(context)
                  .copyWith(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: selectedDateRange,
              builder: (BuildContext context, Widget? child) {
                return Center(
                  child: SizedBox(
                    width: ResponsiveBreakpoints.of(context).largerThan(DESKTOP)
                        ? 400
                        : 300, // Responsive width
                    height:
                        ResponsiveBreakpoints.of(context).largerThan(DESKTOP)
                            ? 500
                            : 350, // Responsive height
                    child: child,
                  ),
                );
              },
            );
            if (picked != null) {
              setState(() {
                selectedDateRange = picked;
              });
            }
          },
          child: Wrap(
            children: [
              Text(
                '${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
                style: TextStyles.getBodyTextStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  const _StatisticsGrid();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: ResponsiveSizes.getPadding(context),
        runSpacing: ResponsiveSizes.getPadding(context),
        children: [
          const _StatCard(
            title: 'Total Orders',
            value: 'KSh 126,500',
            increase: 34.7,
            icon: Icons.shopping_bag,
            color: Colors.blue,
          ),
          const _StatCard(
            title: 'Active Orders',
            value: 'KSh 126,500',
            increase: 34.7,
            icon: Icons.running_with_errors,
            color: Colors.green,
          ),
          const _StatCard(
            title: 'Completed Orders',
            value: 'KSh 126,500',
            increase: 34.7,
            icon: Icons.check_circle,
            color: Colors.orange,
          ),
          GestureDetector(
            onTap: () {
             // uploadCsvToFirestore();
            },
            child: const _StatCard(
              title: 'Return Orders',
              value: 'KSh 126,500',
              increase: 34.7,
              icon: Icons.replay,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double increase;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.increase,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP) ? 220 : 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    SizedBox(width: ResponsiveSizes.getPadding(context)),
                    Text(
                      title,
                      style: TextStyles.getSubtitleStyle(context),
                    ),
                  ],
                ),
                const Icon(Icons.more_vert),
              ],
            ),
            SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColorsnStylesConstants.primaryColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: ResponsiveSizes.getPadding(context)),
                Text(
                  value,
                  style: TextStyles.getTitleStyle(context),
                ),
                const Spacer(),
                const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                Text('${increase.toStringAsFixed(1)}%',
                    style: TextStyles.getBodyTextStyle(context)),
              ],
            ),
            SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Compared to Oct 2023',
                style: TextStyles.getBodyTextStyle(context).copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesGraph extends StatefulWidget {
  @override
  State<_SalesGraph> createState() => _SalesGraphState();
}

class _SalesGraphState extends State<_SalesGraph> {
  String selectedPeriod = 'MONTHLY';

  final Map<String, List<FlSpot>> periodData = {
    'WEEKLY': [
      const FlSpot(0, 70),
      const FlSpot(1, 60),
      const FlSpot(2, 80),
      const FlSpot(3, 90),
      const FlSpot(4, 50),
      const FlSpot(5, 100),
      const FlSpot(6, 120),
    ],
    'MONTHLY': [
      const FlSpot(0, 50),
      const FlSpot(1, 55),
      const FlSpot(2, 60),
      const FlSpot(3, 80),
      const FlSpot(4, 70),
      const FlSpot(5, 90),
    ],
    'YEARLY': [
      const FlSpot(0, 200),
      const FlSpot(1, 250),
      const FlSpot(2, 300),
      const FlSpot(3, 400),
      const FlSpot(4, 350),
      const FlSpot(5, 450),
    ],
  };

  final Map<String, List<String>> labels = {
    'WEEKLY': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'MONTHLY': ['JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'],
    'YEARLY': ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'],
  };

  @override
  Widget build(BuildContext context) {
    final int dataLength = periodData[selectedPeriod]!.length;
    double interval = (dataLength > 6) ? (dataLength / 6).ceilToDouble() : 1.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sales Graph',
                  style: TextStyles.getBodyTextStyle(context)
                      .copyWith(fontSize: 18),
                ),
                DropdownButton<String>(
                  value: selectedPeriod,
                  items: [
                    DropdownMenuItem(
                        value: 'WEEKLY',
                        child: Text(
                          'WEEKLY',
                          style: TextStyles.getBodyTextStyle(context),
                        )),
                    DropdownMenuItem(
                        value: 'MONTHLY',
                        child: Text(
                          'MONTHLY',
                          style: TextStyles.getBodyTextStyle(context),
                        )),
                    DropdownMenuItem(
                        value: 'YEARLY',
                        child: Text(
                          'YEARLY',
                          style: TextStyles.getBodyTextStyle(context),
                        )),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPeriod = newValue!;
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final titles = labels[selectedPeriod]!;
                          if (index >= 0 && index < titles.length) {
                            return Text(titles[index]);
                          }
                          return const SizedBox.shrink();
                        },
                        interval: interval,
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'KSh ${value.toInt()}',
                            style: TextStyles.getBodyTextStyle(context),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: periodData[selectedPeriod]!,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                      dotData: const FlDotData(
                        show: true,
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.black54,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(
                            'KSh ${touchedSpot.y}',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestSellers extends StatelessWidget {
  const _BestSellers();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Best Sellers',
                  style: TextStyles.getBodyTextStyle(context)
                      .copyWith(fontSize: 18),
                ),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  title: Text(
                    'Lorem Ipsum',
                    style: TextStyles.getBodyTextStyle(context),
                  ),
                  subtitle: Text(
                    'KSh 126,500',
                    style: TextStyles.getBodyTextStyle(context),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'KSh 126.50',
                        style: TextStyles.getBodyTextStyle(context),
                      ),
                      Text(
                        '999 sales',
                        style: TextStyles.getBodyTextStyle(context),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'REPORT',
                style: TextStyles.getBodyTextStyle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentOrders extends StatelessWidget {
  const _RecentOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
          ? double.infinity
          : MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: TextStyles.getTitleStyle(context),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Text(
                      'Product',
                      style: TextStyles.getSubtitleStyle(context),
                    )),
                    DataColumn(
                        label: Text(
                      'Order ID',
                      style: TextStyles.getSubtitleStyle(context),
                    )),
                    DataColumn(
                        label: Text(
                      'Date',
                      style: TextStyles.getSubtitleStyle(context),
                    )),
                    DataColumn(
                        label: Text(
                      'Customer',
                      style: TextStyles.getSubtitleStyle(context),
                    )),
                    DataColumn(
                        label: Text(
                      'Status',
                      style: TextStyles.getSubtitleStyle(context),
                    )),
                    DataColumn(
                        label: Text(
                      'Amount',
                      style: TextStyles.getSubtitleStyle(context),
                    )),
                  ],
                  rows: [
                    _buildDataRow('Lorem Ipsum', '#25426', 'Nov 8th, 2023',
                        'Kavin', 'Delivered', 'KSh 200.00', context),
                    _buildDataRow('Lorem Ipsum', '#25425', 'Nov 7th, 2023',
                        'Komael', 'Canceled', 'KSh 200.00', context),
                    _buildDataRow('Lorem Ipsum', '#25424', 'Nov 6th, 2023',
                        'Nikhil', 'Delivered', 'KSh 200.00', context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String product, String orderId, String date,
      String customer, String status, String amount, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 100,
            child: Text(product),
          ),
        ),
        DataCell(
          SizedBox(
            width: 110,
            child: Text(orderId),
          ),
        ),
        DataCell(Text(date)),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                child: Text(customer[0]),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(customer)),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  status == 'Delivered' ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyles.getBodyTextStyle(context).copyWith(
                color:
                    status == 'Delivered' ? Colors.green[900] : Colors.red[900],
              ),
            ),
          ),
        ),
        DataCell(Text(
          amount,
          style: TextStyles.getSubtitleStyle(context),
        )),
      ],
    );
  }
}
