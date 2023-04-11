import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/user_info_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/repository/auth_repo.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_card_token.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_installment.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_issuer.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_payment.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_payment_method_installments.dart';
import 'package:flutter_sixvalley_ecommerce/provider/mercado_pago_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/snackbar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/animated_custom_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog_voucher.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/status/client_payments_status_page.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class ClientPaymentsInstallmentsController {
  BuildContext context;
  Function refresh;

  MercadoPagoProvider _mercadoPagoProvider = new MercadoPagoProvider();
  UserInfoModel user;
  // SharedPref _sharedPref = new SharedPref();

  MercadoPagoCardToken cardToken;
  List<Product> selectedProducts = [];
  Product product;
  AuthRepo authRepo;
  MercadoPagoPaymentMethodInstallments installments;
  List<MercadoPagoInstallment> installmentsList = [];
  MercadoPagoIssuer issuer;
  MercadoPagoPayment creditCardPayment;
  MercadoPagoPayment ticket;

  String selectedInstallment;

  // Address address;

  // ProgressDialog progressDialog;

  String identificationType;
  String identificationNumber;
  double total;
  ProgressDialog progressDialog;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;

    Map<String, dynamic> arguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    // cardToken = MercadoPagoCardToken.fromJsonMap(arguments['card_token']);
    identificationType = arguments['identification_type'];
    identificationNumber = arguments['identification_number'];
    total = arguments['total'];

    progressDialog = ProgressDialog(context: context);

    _mercadoPagoProvider.init(context, user);

    getInstallments();
  }

  void getInstallments() async {
    installments = await _mercadoPagoProvider.getInstallments(
        cardToken.firstSixDigits, total);
    //print('OBJECT INSTALLMENTS: ${installments.toJson()}');

    installmentsList = installments.payerCosts;
    issuer = installments.issuer;

    refresh();
  }

  //EFECTY
  createPayEfecty(double total, String email, String description) async {
    Response response = await _mercadoPagoProvider.createPaymentEfecty(
        transactionAmount: total,
        emailCustomer: email,
        description: description,
        paymentMethodId: "efecty");

    print('Response code: ${response.statusCode}');
    final data = json.decode(response.body);
    if (response != null) {
      var formatter = NumberFormat('#,###,000');
      if (response.statusCode == 200) {
        print('SE GENERO UN PAGO efecty ${response.body}');
        ticket = MercadoPagoPayment.fromJsonMap2(data);
        print(ticket.id);
        print(ticket.transactionAmount);
        print(ticket.status);
        print(total);
        refresh();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => DashBoardScreen()),
            (route) => false);
        showAnimatedDialog(
            context,
            MyDialogVoucher(
              icon: Icons.check,
              title: '¡Pedido realizado con éxito!',
              description: 'Haz tu pago en cualquier punto efecty',
              conventionId: '110757',
              id: '${ticket.id}',
              total: '\$ ' + formatter.format(total.toInt()),
              isFailed: false,
              isBaloto: false,
              isEfecty: true,
            ),
            dismissible: false,
            isFlip: true);
        // MySnackbar.show(context, 'Referencia de pago: ${ticket.id}');

        return ticket.id;
      }
    }
  }

  //BALOTO
  createPayBaloto(double total, String email, String description) async {
    Response response = await _mercadoPagoProvider.createPaymentBaloto(
        transactionAmount: total,
        emailCustomer: email,
        description: description,
        paymentMethodId: "baloto");

    print('Response code: ${response.statusCode}');
    final data = json.decode(response.body);

    if (response != null) {
      if (response.statusCode == 200) {
        var formatter = NumberFormat('#,###,000');
        print('SE GENERO UN PAGO baloto ${response.body}');
        ticket = MercadoPagoPayment.fromJsonMap2(data);
        print(ticket.id);
        refresh();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => DashBoardScreen()),
            (route) => false);
        showAnimatedDialog(
            context,
            MyDialogVoucher(
              icon: Icons.check,
              title: '¡Pedido realizado con éxito!',
              description:
                  'Haz tu pago en cualquier punto Baloto\ncon los siguientes datos',
              conventionId: '951538',
              id: '${ticket.id}',
              total: '\$ ' + formatter.format(total.toInt()),
              isFailed: false,
              isBaloto: true,
              isEfecty: false,
            ),
            dismissible: false,
            isFlip: true);
        // MySnackbar.show(context, 'Referencia de pago: ${ticket.id}');

        return ticket.id;
      }
    }

    // return MySnackbar.show(context, ticket.id);
  }

  void createPay() async {
    if (selectedInstallment == null) {
      MySnackbar.show(context, 'Debes seleccionar el numero de coutas');
      return;
    }

    ProductModel order = new ProductModel(products: selectedProducts);

    progressDialog.show(max: 100, msg: 'Realizando transaccion');

    Response response = await _mercadoPagoProvider.createPayment(
        description: 'Jero - prueba card',
        transactionAmount: total,
        installments: int.parse(selectedInstallment),
        paymentMethodId: installments.paymentMethodId,
        paymentTypeId: installments.paymentTypeId,
        issuerId: int.parse(installments.issuer.id),
        emailCustomer: Provider.of<ProfileProvider>(context, listen: false)
            .userInfoModel
            .email,
        cardToken: cardToken.id,
        identificationType: identificationType,
        identificationNumber: identificationNumber
        // order: order,
        );
    print('response.body');
    print(response.body);
    print(response.statusCode);

    progressDialog.close();

    // print('SE GENERO UN PAGO antes ${response.body}');

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      print('SE GENERO UN PAGO ${response.body}');

      creditCardPayment = MercadoPagoPayment.fromJsonMap2(data);

      // Navigator.pushAndRemoveUntil(context,
      //     MaterialPageRoute(builder: (context) {
      //   return ClientPaymentsStatusPage();
      // }), (route) => false);

      Navigator.pushNamedAndRemoveUntil(
          context, 'client/payments/status', (route) => false,
          arguments: creditCardPayment.toJson());
      print('CREDIT CART PAYMENT ${creditCardPayment.toJson()}');
    }
    if (response.statusCode != 200) {
      // Navigator.pushAndRemoveUntil(context,
      //     MaterialPageRoute(builder: (context) {
      //   return ClientPaymentsStatusPage();
      // }), (route) => false);

      // print('CREDIT CART PAYMENT ${creditCardPayment.toJson()}');
    } else if (response.statusCode == 501) {
      if (data['err']['status'] == 400) {
        badRequestProcess(data);
      } else {
        badTokenProcess(data['status'], installments);
      }
    }
  }

  ///SI SE RECIBE UN STATUS 400
  void badRequestProcess(dynamic data) {
    Map<String, String> paymentErrorCodeMap = {
      '3034': 'Informacion de la tarjeta invalida',
      '205': 'Ingresa el número de tu tarjeta',
      '208': 'Digita un mes de expiración',
      '209': 'Digita un año de expiración',
      '212': 'Ingresa tu documento',
      '213': 'Ingresa tu documento',
      '214': 'Ingresa tu documento',
      '220': 'Ingresa tu banco emisor',
      '221': 'Ingresa el nombre y apellido',
      '224': 'Ingresa el código de seguridad',
      'E301': 'Hay algo mal en el número. Vuelve a ingresarlo.',
      'E302': 'Revisa el código de seguridad',
      '316': 'Ingresa un nombre válido',
      '322': 'Revisa tu documento',
      '323': 'Revisa tu documento',
      '324': 'Revisa tu documento',
      '325': 'Revisa la fecha',
      '326': 'Revisa la fecha'
    };
    String errorMessage;
    print('CODIGO ERROR ${data['err']['cause'][0]['code']}');

    if (paymentErrorCodeMap.containsKey('${data['err']['cause'][0]['code']}')) {
      print('ENTRO IF');
      errorMessage = paymentErrorCodeMap['${data['err']['cause'][0]['code']}'];
    } else {
      errorMessage = 'No pudimos procesar tu pago';
    }
    // MySnackbar.show(context, errorMessage);
    // Navigator.pop(context);
  }

  void badTokenProcess(
      String status, MercadoPagoPaymentMethodInstallments installments) {
    Map<String, String> badTokenErrorCodeMap = {
      '106': 'No puedes realizar pagos a usuarios de otros paises.',
      '109':
          '${installments.paymentMethodId} no procesa pagos en ${selectedInstallment} cuotas',
      '126': 'No pudimos procesar tu pago.',
      '129':
          '${installments.paymentMethodId} no procesa pagos del monto seleccionado.',
      '145': 'No pudimos procesar tu pago',
      '150': 'No puedes realizar pagos',
      '151': 'No puedes realizar pagos',
      '160': 'No pudimos procesar tu pago',
      '204':
          '${installments.paymentMethodId} no está disponible en este momento.',
      '801':
          'Realizaste un pago similar hace instantes. Intenta nuevamente en unos minutos',
    };
    String errorMessage;
    if (badTokenErrorCodeMap.containsKey(status.toString())) {
      errorMessage = badTokenErrorCodeMap[status];
    } else {
      errorMessage = 'No pudimos procesar tu pago';
    }
    // MySnackbar.show(context, errorMessage);
    // Navigator.pop(context);
  }
}
