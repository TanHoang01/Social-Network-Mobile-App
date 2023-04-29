import 'package:flutter/material.dart';
import 'package:gamestation/components/socal_cart.dart';
import 'package:gamestation/components/have_account_text.dart';
import 'package:gamestation/constants.dart';

import 'sign_up_form.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10), 
                Text("Register Account", style: headingStyle),
                Text(
                  "Complete your details or continue \nwith social media",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                SignUpForm(),
                SizedBox(height: 20),
                HaveAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}