import 'package:flutter/material.dart';
import 'package:test_work_app/components/my_button.dart';
import 'package:test_work_app/components/my_input.dart';
import 'package:test_work_app/pages/add_info_page.dart';
import 'package:test_work_app/services/RegisterService.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Registerservice registerservice = Registerservice();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2.7,
          padding: EdgeInsets.symmetric(vertical: 5),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),

          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: 5,
            child: ListView(
              children: [
                MyInput(text: "Email", controller: emailController),
                MyInput(text: "Password", controller: passwordController),
                MyButton(
                  color: Colors.indigoAccent,
                  text: "Войти",
                  onTap: () => reg(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void reg() async {
    if (emailController.text.isNotEmpty || passwordController.text.isNotEmpty) {
      String reg = await registerservice.register(
        email: emailController.text,
        password: passwordController.text,
      );
      if (reg == "login"){
        await registerservice.login(email: emailController.text, password: passwordController.text);
      }
      //if (reg == "ok"){
        //Navigator.pop(context);
        //Navigator.push(context, MaterialPageRoute(builder: (context) => AddInfoPage()));
     // }
    }
  }
}
