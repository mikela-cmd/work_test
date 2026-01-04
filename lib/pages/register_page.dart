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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String text = "";
  bool _isLoading = false;

  @override
  void dispose() {
    // Очищаем контроллеры при удалении виджета
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isreg ? register() : login();
  }

  Widget login() {
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Вход в аккаунт",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
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
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : MyButton(
                        color: Colors.indigoAccent,
                        text: "Войти",
                        onTap: () => log(),
                      ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (mounted) {
                            setState(() {
                              _isreg = true;
                            });
                          }
                        },
                  child: Text(
                    "Нет аккаунта? Зарегистрироваться",
                    style: TextStyle(color: Colors.indigoAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget register() {
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
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "Регистрация",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
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
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : MyButton(
                        color: Colors.indigoAccent,
                        text: "Зарегистрироваться",
                        onTap: () => reg(),
                      ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (mounted) {
                            setState(() {
                              _isreg = false;
                            });
                          }
                        },
                  child: Text(
                    "Есть аккаунт? Войти",
                    style: TextStyle(color: Colors.indigoAccent, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> reg() async {
    if (!mounted) return;

    // Проверка полей ввода
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          text = "Заполните все поля";
        });
      }
      return;
    }

    // Валидация email
    if (!emailController.text.contains("@") ||
        !emailController.text.contains(".com")) {
      if (mounted) {
        setState(() {
          text = "Неверный email (XXXXX@XXXXX.com)";
        });
      }
      return;
    }

    // Показываем индикатор загрузки
    if (mounted) {
      setState(() {
        _isLoading = true;
        text = "";
      });
    }

    try {
      String reg = await registerservice.register(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      switch (reg) {
        case "email exist":
          setState(() {
            text = "Аккаунт с такой почтой существует";
            _isLoading = false;
          });
          break;
        case "week password":
          setState(() {
            text = "Слабый пароль";
            _isLoading = false;
          });
          break;
        case "error":
          setState(() {
            text = "Ошибка регистрации";
            _isLoading = false;
          });
          break;
        case "ok":
          // Успешная регистрация - переходим на следующую страницу
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddInfoPage()),
          );
          break;
        default:
          setState(() {
            text = "Неизвестная ошибка";
            _isLoading = false;
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        text = "Ошибка подключения";
        _isLoading = false;
      });
    }
  }

  Future<void> log() async {
    if (!mounted) return;

    // Проверка полей ввода
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      if (mounted) {
        setState(() {
          text = "Заполните все поля";
        });
      }
      return;
    }

    // Валидация email
    if (!emailController.text.contains("@") ||
        !emailController.text.contains(".com")) {
      if (mounted) {
        setState(() {
          text = "Неверный email (XXXXX@XXXXX.com)";
        });
      }
      return;
    }

    // Показываем индикатор загрузки
    if (mounted) {
      setState(() {
        _isLoading = true;
        text = "";
      });
    }

    try {
      String log = await registerservice.login(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      switch (log) {
        case "invalid_password":
          setState(() {
            text = "Неверный пароль";
            _isLoading = false;
          });
          break;
        case "error":
          setState(() {
            text = "Ошибка входа";
            _isLoading = false;
          });
          break;
        case "ok":
          // Успешный вход - переходим на следующую страницу
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddInfoPage()),
          );
          break;
        default:
          setState(() {
            text = "Аккаунта с такой почтой не существует";
            _isLoading = false;
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        text = "Ошибка подключения";
        _isLoading = false;
      });
    }
  }
}