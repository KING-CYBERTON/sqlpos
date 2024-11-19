import 'package:flutter/material.dart';

import '../../constants/sizes_constants.dart';
import '../../constants/text_styles_constants.dart';

class AdminUserDetails extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onBack;

  const AdminUserDetails({super.key, required this.user, required this.onBack});

  @override
  AdminUserDetailsState createState() => AdminUserDetailsState();
}

class AdminUserDetailsState extends State<AdminUserDetails> {
  late Map<String, dynamic> _editableUser;

  @override
  void initState() {
    super.initState();
    _editableUser = Map.from(widget.user);
  }

  Widget _buildEditableCard(
      String title, List<MapEntry<String, dynamic>> fields) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      margin: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyles.getTitleStyle(context)),
            SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
            ...fields
                .map((entry) => _buildEditableField(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: ResponsiveSizes.getPadding(context) / 2),
      child: TextFormField(
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (newValue) {
          setState(() {
            _editableUser[label] = newValue;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onBack,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_back_ios, size: 20),
              const SizedBox(width: 5),
              Text(
                'Back to Users List',
                style: TextStyles.getBodyTextStyle(context)
                    .copyWith(color: Colors.blue),
              ),
            ],
          ),
        ),
        SizedBox(height: ResponsiveSizes.getPadding(context) * 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'User Details for ID: ${_editableUser['userId']}',
              style: TextStyles.getTitleStyle(context),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSizes.getPadding(context) * 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildEditableCard('Personal Information', [
                MapEntry('User ID', _editableUser['userId']),
                MapEntry('Full Name', _editableUser['fullName']),
                MapEntry('National ID', _editableUser['nationalId']),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildEditableCard('Contact Information', [
                MapEntry('Telephone', _editableUser['telephone']),
                MapEntry('Email', _editableUser['email']),
              ]),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildEditableCard('Account Information', [
                MapEntry('Date Created', _editableUser['dateCreated']),
                MapEntry('Date Modified', _editableUser['dateModified']),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildEditableCard('Additional Information', [
                const MapEntry(
                    'Account Status', 'Active'), // Assuming a default status
                const MapEntry('Last Login',
                    'N/A'), // This field is not in the original data, so we're adding it as an example
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
