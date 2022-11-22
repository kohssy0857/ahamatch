import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

int devideUser(User user) {
  String? dispname = user.displayName;
  if (dispname!.contains("-")) {
    return 0;
  } else if (dispname.contains("#")) {
    return 1;
  } else {
    return 2;
  }
}
