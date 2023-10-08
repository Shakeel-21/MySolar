import 'package:flutter/material.dart';
import 'package:my_solar_app/cloud_functions/authentication/auth_repository.dart';
import 'package:my_solar_app/cloud_functions/database/database_api.dart';
import 'package:my_solar_app/cloud_functions/database/interfaces/user_persistence_interface.dart';
import 'package:my_solar_app/widgets/authentication/text_field.dart';
import 'package:my_solar_app/cloud_functions/authentication/interfaces/auth_repository_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final IAuthRepository authentication = AuthRepository();
  final IUserPersistence userPersistence = DatabaseApi();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  ColorLabel systemType = ColorLabel.manual;

  final supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    final TextEditingController colorController = TextEditingController();
    final List<DropdownMenuEntry<ColorLabel>> colorEntries =
        <DropdownMenuEntry<ColorLabel>>[];
    for (ColorLabel color in ColorLabel.values) {
      colorEntries.add(
        DropdownMenuEntry<ColorLabel>(
          value: color,
          label: color.toString(),
        ),
      );
    }
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/my_solar_logo.png',
          scale: 3,
        ),
        /* const Text("Register"), */
        //shows user name and password text boxes
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownMenu<ColorLabel>(
                    width: 300,
                    initialSelection: ColorLabel.manual,
                    controller: colorController,
                    label: const Text('System Type'),
                    dropdownMenuEntries: colorEntries,
                    onSelected: (ColorLabel? color) {
                      setState(() {
                        systemType = color!;
                      });
                    }),
              ]),
        ),

        LoginPageTextField(
          controller: emailController,
          hintText: "Email",
          obscureText: false,
          textType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        LoginPageTextField(
          controller: passwordController,
          hintText: 'Password',
          obscureText: true,
          textType: TextInputType.text,
        ),

        //aligns password to the right
        // const Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     Padding(
        //         padding: EdgeInsets.fromLTRB(0, 5, 50, 0),
        //         child: Text("Forgot Password?"))
        //   ],
        // ),
        const SizedBox(height: 20),

        //creates Sign In button
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(300, 70)),
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                //TODO also upload user to our database and upload their solarsystem setup
                try {
                  await authentication.signUpEmailAndPassword(email, password);
                  //uploads user to database
                  //final convertSystem = convertSystemEnumToValue(systemType);
                  //TODO figure out what the fuck is happening here
                  //code is unreadable
                  //I am losing my mind
                  await userPersistence.createUser(
                      email, 1, password, 'something');
                  Navigator.of(context)
                      .pushReplacementNamed('/register_system');
                } on AuthException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(error.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text("Error occured please try again"),
                      backgroundColor: Theme.of(context).colorScheme.error));
                }
              },
              child: const Text("Next")),
        ]),
        const SizedBox(height: 25),

        //creates divider with text continue with
        // const Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Text("Or continue with"),
        //   ],
        // ),
        // const SizedBox(
        //   height: 25,
        // ),
        // const Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     SquareImageTile(imagePath: 'assets/images/google.png'),
        //     SizedBox(width: 40),
        //     SquareImageTile(imagePath: 'assets/images/apple.png')
        //   ],
        // ),
        const SizedBox(
          height: 30,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('already have an account? '),
            Text(
              'Login now',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            )
          ],
        )
      ],
    )));
  }
}

convertSystemEnumToValue(ColorLabel color) {
  if (color == ColorLabel.manual) {
    return 0;
  } else if (ColorLabel.solarman == color) {
    return 1;
  }
}

enum ColorLabel {
  manual,
  solarman;
}
