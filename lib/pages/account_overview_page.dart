import 'package:flutter/material.dart';

class AccountOverviewPage extends StatelessWidget {
  const AccountOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: ListView(
        children: const [
          ListTile(title: Text('Name'), subtitle: Text('Vendor Name')),
          ListTile(title: Text('Language'), subtitle: Text('Hindi')),
          ListTile(
              title: Text('Payment Setup'),
              trailing: Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}
