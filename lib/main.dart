import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_work_app/firebase_options.dart';
import 'package:test_work_app/pages/main_page.dart';
import 'package:test_work_app/pages/profile_page.dart';
import 'package:test_work_app/services/AuthGate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: "https://lyuoufibdmksriphxqyu.supabase.co",
    anonKey: "sb_publishable_UthtV_d8nXvKYUVTCuq8yg_oqrfWwpK",
  );
  runApp(MaterialApp(home: AuthGate()));
}
