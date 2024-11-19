import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../constants/sizes_constants.dart';
import '../../constants/text_styles_constants.dart';
import 'admin_user_details.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  UsersListState createState() => UsersListState();
}

class UsersListState extends State<UsersList> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool isViewUserDetail = false;
  Map<String, dynamic>? selectedUser;
  final List<Map<String, dynamic>> _userData = [
    {
      'userId': 'USR001',
      'fullName': 'John Doe',
      'telephone': '+254712345678',
      'email': 'john.doe@example.com',
      'nationalId': '12345678',
      'dateCreated': '2024-10-05 14:32:45',
      'dateModified': '2024-10-06 09:15:30',
      'selected': false,
    },
    {
      'userId': 'USR002',
      'fullName': 'Jane Smith',
      'telephone': '+254723456789',
      'email': 'jane.smith@example.com',
      'nationalId': '87654321',
      'dateCreated': '2024-10-04 10:20:15',
      'dateModified': '2024-10-05 16:45:00',
      'selected': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredAndPaginatedData {
    final filteredData = _userData;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return filteredData.sublist(startIndex,
        endIndex > filteredData.length ? filteredData.length : endIndex);
  }

  void _toggleSelection(int index, bool? value) {
    setState(() {
      _userData[index]['selected'] = value ?? false;

      selectedUser = value == true ? _userData[index] : null;
    });
  }

  void _showDropdownMenu(BuildContext context) {
    final selectedItems = _userData.where((user) => user['selected']).toList();
    if (selectedItems.isNotEmpty) {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
        items: [
          PopupMenuItem(
            child: Text('Delete Selected',
                style: TextStyles.getSubtitleStyle(context)),
            onTap: () {
              setState(() {
                _userData.removeWhere((user) => user['selected']);
              });
            },
          ),
          PopupMenuItem(
            child: Text('View Transaction',
                style: TextStyles.getSubtitleStyle(context)),
            onTap: () {
              if (selectedItems.length == 1) {
                setState(() {
                  selectedUser = selectedItems.first;
                  isViewUserDetail = true;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select only one transaction',
                        style: TextStyles.getSubtitleStyle(context)),
                  ),
                );
              }
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const UserListDateRangePickerPopup(),
          SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
          isViewUserDetail == false
              ? Column(
                  children: [
                    _buildUserTable(context),
                    SizedBox(
                        height: ResponsiveSizes.getSizedBoxHeight(context)),
                    _buildPagination(context),
                  ],
                )
              : selectedUser != null
                  ? AdminUserDetails(
                      user: selectedUser!,
                      onBack: () => setState(() => isViewUserDetail = false),
                    )
                  : Center(
                      child: Text('No transaction selected',
                          style: TextStyles.getSubtitleStyle(context))),
        ],
      ),
    );
  }

  Widget _buildUserTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Users List",
                  style: TextStyles.getTitleStyle(context),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showDropdownMenu(context),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                    label: Text('User Id',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Full Name',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Telephone',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Email',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('National ID',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Date Created',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Date Modified',
                        style: TextStyles.getSubtitleStyle(context))),
              ],
              rows: _filteredAndPaginatedData.map((user) {
                return DataRow(
                  color: WidgetStateProperty.all(Colors.white),
                  selected: user['selected'] ?? false,
                  onSelectChanged: (selected) {
                    _toggleSelection(_userData.indexOf(user), selected);
                  },
                  cells: [
                    DataCell(Text(user['userId'],
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(user['fullName'],
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(user['telephone'],
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(user['email'],
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(user['nationalId'],
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(
                        DateFormat('dd/MM/yyyy HH:mm:ss')
                            .format(DateTime.parse(user['dateCreated'])),
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(
                        DateFormat('dd/MM/yyyy HH:mm:ss')
                            .format(DateTime.parse(user['dateModified'])),
                        style: TextStyles.getBodyTextStyle(context))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    final int totalPages = (_userData.length / _itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              _currentPage > 1 ? () => setState(() => _currentPage--) : null,
        ),
        for (int i = 1; i <= totalPages; i++)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSizes.getPadding(context) / 2),
            child: ElevatedButton(
              onPressed: () => setState(() => _currentPage = i),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentPage == i ? Colors.blue : Colors.grey[200],
              ),
              child: Text(
                i.toString(),
                style: TextStyles.getBodyTextStyle(context).copyWith(
                  color: _currentPage == i ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }
}

class UserListDateRangePickerPopup extends StatefulWidget {
  const UserListDateRangePickerPopup({super.key});

  @override
  UserListDateRangePickerPopupState createState() =>
      UserListDateRangePickerPopupState();
}

class UserListDateRangePickerPopupState
    extends State<UserListDateRangePickerPopup> {
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
              'Order List',
              style: TextStyles.getTitleStyle(context),
            ),
            const SizedBox(height: 5),
            Text('Home > Order List',
                style: TextStyles.getSubtitleStyle(context)
                    .copyWith(color: Colors.grey)),
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
                  style: TextStyles.getSubtitleStyle(context)),
            ],
          ),
        ),
      ],
    );
  }
}
