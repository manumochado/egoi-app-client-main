import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/create/client_payments_create_page.dart';

import 'client_payments_status_controller.dart';

class ClientPaymentsStatusPage extends StatefulWidget {
  const ClientPaymentsStatusPage({Key key}) : super(key: key);

  @override
  _ClientPaymentsStatusPageState createState() =>
      _ClientPaymentsStatusPageState();
}

class _ClientPaymentsStatusPageState extends State<ClientPaymentsStatusPage> {
  ClientPaymentsStatusController _con = new ClientPaymentsStatusController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_clipPathOval(), _textCardDetail(), _textCardStatus()],
      ),
      bottomNavigationBar: Container(
        height: 100,
        child: _buttonNext(),
      ),
    );
  }

  Widget _textCardDetail() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: _con.mercadoPagoPayment?.status == 'approved'
          ? Text(
              'Tu orden fue procesada exitosamente usando (${_con.mercadoPagoPayment?.paymentMethodId?.toUpperCase() ?? ''} **** ${_con.mercadoPagoPayment?.card?.lastFourDigits ?? ''})',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            )
          : Text(
              'Tu pago fue rechazado',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _textCardStatus() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: _con.mercadoPagoPayment?.status == 'approved'
          ? Text(
              'Mira el estado de tu compra en la seccion de MIS PEDIDOS',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            )
          : Text(
              _con.errorMessage ?? '',
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.center,
            ),
    );
  }

  Widget _clipPathOval() {
    return ClipPath(
      child: Container(
        height: 250,
        width: double.infinity,
        color: ThemeData().primaryColor,
        child: SafeArea(
          child: Column(
            children: [
              _con.mercadoPagoPayment?.status == 'approved'
                  ? Icon(Icons.check_circle, color: Colors.green, size: 150)
                  : Icon(Icons.cancel, color: Colors.red, size: 150),
              Text(
                _con.mercadoPagoPayment?.status == 'approved'
                    ? 'Gracias por tu compra'
                    : 'Fallo la transaccion',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonNext() {
    return Container(
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          return Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return ClientPaymentsCreatePage();
          }), (route) => false);
        },
        style: ElevatedButton.styleFrom(
            primary: ThemeData().primaryColor,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'FINALIZAR COMPRA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 2),
                height: 30,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
