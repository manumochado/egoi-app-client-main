import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/order_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/user_info_model.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_document_type.dart';
import 'package:flutter_sixvalley_ecommerce/models/mercado_pago_payment_method_installments.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class MercadoPagoProvider {
  String _urlMercadoPago = 'api.mercadopago.com';
  String _url = AppConstants.BASE_URL;
  final _mercadoPagoCredentials = AppConstants.mercadoPagoCredentials;
  DioClient dioClient;
  BuildContext context;
  UserInfoModel user;

  Future init(BuildContext context, UserInfoModel user) {
    this.context = context;
    this.user = user;
  }

  Future<List<MercadoPagoDocumentType>> getIdentificationTypes() async {
    try {
      final url = Uri.https(_urlMercadoPago, '/v1/identification_types',
          {'access_token': _mercadoPagoCredentials.accessToken});

      final res = await http.get(url);
      final data = json.decode(res.body);
      final result = new MercadoPagoDocumentType.fromJsonList(data);

      return result.documentTypeList;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Response> createPayment({
    // @required String cardId,
    @required double transactionAmount,
    @required int installments,
    @required String paymentMethodId,
    @required String paymentTypeId,
    @required int issuerId,
    @required String emailCustomer,
    @required String cardToken,
    @required String identificationType,
    @required String identificationNumber,
    @required String description,
    // @required ProductModel order,
  }) async {
    try {
      final url = Uri.parse('https://egoi.xyz/api/v2/mercadopago/card');

      Map<String, dynamic> body = {
        // 'order': order,
        // 'card_id': cardId,
        'description': description,
        'transaction_amount': transactionAmount,
        'installments': installments,
        'payment_method_id': paymentMethodId,
        'payment_type_id': paymentTypeId,
        'token': cardToken,
        'issuer_id': issuerId,
        'payer': {
          'email': emailCustomer,
          'identification': {
            'type': identificationType,
            'number': identificationNumber
          }
        }
      };
      // print('token: ${dioClient.token}');
      print('PARAMS bajo token: ${body}');

      String bodyParams = json.encode(body);

      Map<String, String> headers = {
        'Content-type': 'application/json',
      };

      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        // Fluttertoast.showToast(msg: 'Sesion expirada');
        // new SharedPref().logout(context, user.id);
        return null;
      }

      return res;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<MercadoPagoPaymentMethodInstallments> getInstallments(
      String bin, double amount) async {
    try {
      final url =
          Uri.https(_urlMercadoPago, '/v1/payment_methods/installments', {
        'access_token': _mercadoPagoCredentials.accessToken,
        'bin': bin,
        'amount': '${amount}'
      });

      final res = await http.get(url);
      final data = json.decode(res.body);
      print('DATA INSTALLMENTS: $data');

      final result =
          new MercadoPagoPaymentMethodInstallments.fromJsonList(data);

      return result.installmentList.first;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<http.Response> createCardToken({
    String cvv,
    String expirationYear,
    int expirationMonth,
    String cardNumber,
    String documentNumber,
    String documentId,
    String cardHolderName,
  }) async {
    try {
      final url = Uri.https(_urlMercadoPago, '/v1/card_tokens',
          {'public_key': _mercadoPagoCredentials.publicKey});

      final body = {
        'security_code': cvv,
        'expiration_year': expirationYear,
        'expiration_month': expirationMonth,
        'card_number': cardNumber,
        'cardholder': {
          'identification': {
            'number': documentNumber,
            'type': documentId,
          },
          'name': cardHolderName
        },
      };

      final res = await http.post(url, body: json.encode(body));

      return res;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Response> createPaymentEfecty(
      {@required double transactionAmount,
      @required String paymentMethodId,
      @required String emailCustomer,
      @required String description}) async {
    try {
      final url = Uri.parse('https://egoi.xyz/api/v2/mercadopago/ticket');

      Map<String, dynamic> body = {
        'transaction_amount': transactionAmount,
        'description': description,
        'payment_method_id': paymentMethodId,
        'email': emailCustomer,
      };

      print('PARAMS: ${body}');

      String bodyParams = json.encode(body);

      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
        // 'Content-type': 'application/json',
        // 'Authorization': 'Bearer ${dioClient.token}'
      };

      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        // Fluttertoast.showToast(msg: 'Sesion expirada');
        // new SharedPref().logout(context, user.id);
        return null;
      }

      return res;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Response> createPaymentBaloto(
      {@required double transactionAmount,
      @required String paymentMethodId,
      @required String emailCustomer,
      @required String description}) async {
    try {
      final url = Uri.parse('https://egoi.xyz/api/v2/mercadopago/ticket');

      Map<String, dynamic> body = {
        'transaction_amount': transactionAmount,
        'description': description,
        'payment_method_id': paymentMethodId,
        'email': emailCustomer,
      };

      print('PARAMS: ${body}');

      String bodyParams = json.encode(body);

      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8'
        // 'Content-type': 'application/json',
        // 'Authorization': 'Bearer ${dioClient.token}'
      };

      final res = await http.post(url, headers: headers, body: bodyParams);

      if (res.statusCode == 401) {
        // Fluttertoast.showToast(msg: 'Sesion expirada');
        // new SharedPref().logout(context, user.id);
        return null;
      }

      return res;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
