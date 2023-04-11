import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';

class MyDialog extends StatelessWidget {
  final bool isFailed;
  final double rotateAngle;
  final IconData icon;
  final String title;
  final String description;

  bool isEfecty;
  bool isBaloto;
  MyDialog(
      {this.isFailed = false,
      this.rotateAngle = 0,
      @required this.icon,
      @required this.title,
      @required this.description,
      this.isBaloto,
      this.isEfecty});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 0,
            right: 0,
            top: -55,
            child: Container(
              height: 80,
              width: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: isFailed
                      ? ColorResources.getRed(context)
                      : Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
              child: Transform.rotate(
                  angle: rotateAngle,
                  child: Icon(icon, size: 40, color: Colors.white)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(title,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE)),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Text(description,
                  textAlign: TextAlign.center, style: titilliumRegular),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              isEfecty == true
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amber,
                      ),
                      height: MediaQuery.of(context).size.height * 0.055,
                      width: MediaQuery.of(context).size.width * 0.23,
                      child: Image.asset(Images.efecty_logo, fit: BoxFit.cover))
                  : isBaloto == true
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.055,
                          width: MediaQuery.of(context).size.width * 0.255,
                          child: Image.asset(Images.baloto_logo,
                              fit: BoxFit.cover))
                      : SizedBox(),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_LARGE),
                child: CustomButton(
                    buttonText: getTranslated('ok', context),
                    onTap: () => Navigator.pop(context)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
