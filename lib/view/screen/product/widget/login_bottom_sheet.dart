import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/auth/auth_screen.dart';
import 'package:flutter_social_button/flutter_social_button.dart';

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({Key key}) : super(key: key);

  @override
  _LoginBottomSheetState createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        initialChildSize: 1,
        minChildSize: 1,
        maxChildSize: 1,
        builder: (context, scrollController) {
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Images.loginbackground),
                      fit: BoxFit.cover)),
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  // FlutterSocialButton(
                  //   onTap: () {},
                  //   buttonType: ButtonType.facebook,
                  // ),

                  // //For google Button
                  // FlutterSocialButton(
                  //   onTap: () {},
                  //   buttonType: ButtonType.google,
                  //   iconColor: Colors.white,
                  // ),
                  FlutterSocialButton(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return AuthScreen();
                      }));
                    },
                    buttonType: ButtonType.email,
                    iconColor: Colors.white,
                  ),
                ],
              ));
        });
  }
}
