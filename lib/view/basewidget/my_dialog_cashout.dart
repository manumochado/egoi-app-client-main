import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';

class MyDialogCashOut extends StatelessWidget {
  final bool isFailed;
  final double rotateAngle;
  final String title;
  String description;
  String description2;
  String image;
  String conventionId;
  bool isEfecty;
  bool isBaloto;
  MyDialogCashOut(
      {this.isFailed = false,
      this.rotateAngle = 0,
      this.description2,
      @required this.title,
      this.image,
      this.description,
      this.conventionId,
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
            top: isEfecty == true ? -55 : -42,
            child: Container(
              height: isEfecty == true
                  ? MediaQuery.of(context).size.height * 0.1
                  : MediaQuery.of(context).size.height * 0.08,
              width: isEfecty == true
                  ? MediaQuery.of(context).size.height * 0.1
                  : MediaQuery.of(context).size.height * 0.08,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: isFailed
                      ? ColorResources.getRed(context)
                      : isEfecty == true
                          ? Colors.amber
                          : Colors.transparent,
                  shape: BoxShape.circle),
              child: Transform.rotate(
                  angle: rotateAngle,
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  )),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: isEfecty == true ? 40 : 30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(title,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE)),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              isEfecty == true
                  ? Text(description + '.',
                      textAlign: TextAlign.start, style: titilliumRegular)
                  : isBaloto == true
                      ? Text(description2 + '.',
                          textAlign: TextAlign.start, style: titilliumRegular)
                      : SizedBox(),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              Text(conventionId + '.',
                  textAlign: TextAlign.start, style: titilliumRegular),
              SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.PADDING_SIZE_LARGE),
                child: CustomButton(
                    buttonText: 'Continuar',
                    onTap: () => Navigator.pop(context)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
