import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/provider/order_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/animated_custom_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog_cashout.dart';
import 'package:provider/provider.dart';

class CustomCheckBox extends StatefulWidget {
  final String title;
  final int index;
  CustomCheckBox({@required this.title, @required this.index});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        return InkWell(
          onTap: () {
            order.setPaymentMethod(widget.index);
            setState(() {
              widget.title == 'Pagar por Efecty'
                  ? showAnimatedDialog(
                      context,
                      MyDialogCashOut(
                        image: Images.efecty_cashout_logo,
                        title: 'Efecty',
                        description:
                            '● Realiza tu pago en cualquier punto efecty del país, tienes un plazo de 24 horas',
                        conventionId:
                            '● La referencia de pago aparecera cuando confirmes tu pedido, recuerda tomar captura de pantalla',
                        isFailed: false,
                        isBaloto: false,
                        isEfecty: true,
                      ),
                      dismissible: false,
                      isFlip: true)
                  : widget.title == 'Pagar por Baloto'
                      ? showAnimatedDialog(
                          context,
                          MyDialogCashOut(
                            image: Images.baloto_logo,
                            title: 'Baloto',
                            description2:
                                '● Realiza tu pago en cualquier punto baloto del país, tienes un plazo de 24 horas',
                            conventionId:
                                '● La referencia de pago aparecera cuando confirmes tu pedido, recuerda tomar captura de pantalla',
                            isFailed: false,
                            isBaloto: true,
                            isEfecty: false,
                          ),
                          dismissible: false,
                          isFlip: true)
                      : Container();
            });
          },
          child: Row(children: [
            widget.title == 'Pagar por Baloto'
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.03,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Image.asset(Images.baloto_logo, fit: BoxFit.cover))
                : widget.title == 'Pagar por Efecty'
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.amber,
                        ),
                        height: MediaQuery.of(context).size.height * 0.03,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child:
                            Image.asset(Images.efecty_logo, fit: BoxFit.cover))
                    : widget.title == 'Pagar con tarjeta'
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Image.asset(Images.cc, fit: BoxFit.cover))
                        : widget.title == 'Pago contra entrega'
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child:
                                    Image.asset(Images.cod, fit: BoxFit.cover))
                            : SizedBox(),
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.title == 'Pagar por Efecty'
                      ? showAnimatedDialog(
                          context,
                          MyDialogCashOut(
                            image: Images.efecty_cashout_logo,
                            title: 'Efecty',
                            description:
                                '● Realiza tu pago en cualquier punto efecty del país, tienes un plazo de 24 horas',
                            conventionId:
                                '● La referencia de pago aparecera cuando confirmes tu pedido, recuerda tomar captura de pantalla',
                            isFailed: false,
                            isBaloto: false,
                            isEfecty: true,
                          ),
                          dismissible: false,
                          isFlip: true)
                      : widget.title == 'Pagar por Baloto'
                          ? showAnimatedDialog(
                              context,
                              MyDialogCashOut(
                                image: Images.baloto_logo,
                                title: 'Baloto',
                                description2:
                                    '● Realiza tu pago en cualquier punto baloto del país, tienes un plazo de 24 horas',
                                conventionId:
                                    '● La referencia de pago aparecera cuando confirmes tu pedido, recuerda tomar captura de pantalla',
                                isFailed: false,
                                isBaloto: true,
                                isEfecty: false,
                              ),
                              dismissible: false,
                              isFlip: true)
                          : Container();
                });
              },
              child: Checkbox(
                value: order.paymentMethodIndex == widget.index,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (bool isChecked) =>
                    order.setPaymentMethod(widget.index),
              ),
            ),
            Expanded(
              child: Text(widget.title,
                  style: titilliumRegular.copyWith(
                    color: order.paymentMethodIndex == widget.index
                        ? Theme.of(context).textTheme.bodyText1.color
                        : ColorResources.getGainsBoro(context),
                  )),
            ),
          ]),
        );
      },
    );
  }
}
