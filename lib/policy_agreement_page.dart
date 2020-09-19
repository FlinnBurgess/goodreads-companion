import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_policy_page.dart';
import 'privacy_policy_page.dart';
import 'settings.dart';

class PolicyAgreementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GR Bookshelf Companion'),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'By pressing accept, you acknowledge that you have read and agree to the following policies.',
                  ),
                  SizedBox(height: 15,),
                  Divider(),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PrivacyPolicyPage())),
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Privacy Policy',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Icon(Icons.chevron_right)
                              ]))),
                  Divider(),
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DataPolicyPage())),
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Data Policy',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Icon(Icons.chevron_right)
                              ]))),
                  Divider(),
                  SizedBox(height: 5,),
                  RaisedButton(
                    color: Colors.greenAccent,
                    child: Row(mainAxisSize: MainAxisSize.min,
                      children: [Text('Accept'), Icon(Icons.check)],
                    ),
                    onPressed: () => Provider.of<Settings>(context, listen: false).userHasAcceptedPolicies = true,
                  )
                ],
              ))),
    );
  }
}
