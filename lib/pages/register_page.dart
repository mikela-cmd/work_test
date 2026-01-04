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
  bool _isreg = false;
  Registerservice registerservice = Registerservice();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  String text = "";

  @override
  Widget build(BuildContext context) {
    return _isreg ? register() : login();
  }

  Widget login(){
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2.2,
          padding: EdgeInsets.symmetric(vertical: 5),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),

          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: 5,
            child: ListView(
              children: [
                Container(margin: EdgeInsets.symmetric(horizontal: 15),child: Text("Вход в аккаунт", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28), )),
                MyInput(text: "Email", controller: emailController),
                MyInput(text: "Password", controller: passwordController),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                ),
                MyButton(
                  color: Colors.indigoAccent,
                  text: "Войти",
                  onTap: () => log(),
                ),
                TextButton(onPressed: () => setState(() {
                  _isreg = true;
                }), child: Text("Нет аккаунта? Зарегистрироваться", style: TextStyle(color: Colors.indigoAccent, fontSize: 16),)), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget register(){
    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2.2,
          padding: EdgeInsets.symmetric(vertical: 5),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),

          child: Material(
            borderRadius: BorderRadius.circular(15),
            elevation: 5,
            child: ListView(
              children: [
                Container(margin: EdgeInsets.symmetric(horizontal: 15),child: Text("Регистрация", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28), )),
                MyInput(text: "Email", controller: emailController),
                MyInput(text: "Password", controller: passwordController),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    )
                ),
                MyButton(
                  color: Colors.indigoAccent,
                  text: "Зарегистрироваться",
                  onTap: () => reg(),
                ),
                TextButton(onPressed: () => setState(() {
                  _isreg = false;
                }), child: Text("Есть аккаунт? Войти", style: TextStyle(color: Colors.indigoAccent, fontSize: 16),)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void reg() async {
  if (emailController.text.isNotEmpty || passwordController.text.isNotEmpty) {
    if (emailController.text.contains("@") && emailController.text.contains(".com")) {
      String reg = await registerservice.register(
        email: emailController.text,
        password: passwordController.text,
      );
      if (reg == "email exist" || reg == "error"){
        setState(() {
          text = "Аккаунт с такой почтой существует";
        });
      }
      else if(reg == "ok"){
        setState(() {
          text == "";
        });
      }
      else if (reg == "week password") {
        setState(() {
          text = "Слабый пароль";
        });
      } else {
        setState(() {
          text = "Аккаунт существует";
        });
      }
    } else {
      setState(() {
        text = "Неверный email(XXXXX@XXXXX.com)";
      });
    }
  }
  // if (reg == "ok"){
  //   Navigator.pop(context);
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => AddInfoPage()));
  // }
}
    void log() async {
      if (emailController.text.isNotEmpty || passwordController.text.isNotEmpty) {
      if(emailController.text.contains("@") && emailController.text.contains(".com")){

        String log = await registerservice.login(email: emailController.text, password: passwordController.text);
        if (log == "invalid_password" || log == "error"){
          setState(() {
          text = "Неверный пароль или email";
        });}
        }else{
          setState(() {
            text = "Аккаунта с такой почтой не существует";
          });
        }
      }else{
        setState(() {
          text = "Неверный email(XXXXX@XXXXX.com)";
        });
      }
    }
  }

