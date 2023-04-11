import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/provider/localization_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/shimmer_loading.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/seller/seller_screen.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/order_details.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/order_model.dart';

import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/order_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/seller_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/amount_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/show_custom_snakbar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/title_row.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/order/widget/order_details_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/payment_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/support/support_ticket_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/tracking/tracking_screen.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel orderModel;
  final int orderId;
  final String orderType;
  final double extraDiscount;
  final String extraDiscountType;
  OrderDetailsScreen(
      {@required this.orderModel,
      @required this.orderId,
      @required this.orderType,
      this.extraDiscount,
      this.extraDiscountType});

  void _loadData(BuildContext context) async {
    await Provider.of<OrderProvider>(context, listen: false)
        .initTrackingInfo(orderId.toString(), orderModel, true, context);
    if (orderModel == null) {
      await Provider.of<SplashProvider>(context, listen: false)
          .initConfig(context);
    }
    Provider.of<SellerProvider>(context, listen: false).removePrevOrderSeller();
    await Provider.of<ProfileProvider>(context, listen: false)
        .initAddressList(context);
    if (Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .shippingMethod ==
        'sellerwise_shipping') {
      await Provider.of<OrderProvider>(context, listen: false).initShippingList(
        context,
        Provider.of<OrderProvider>(context, listen: false)
            .trackingModel
            .sellerId,
      );
    } else {
      await Provider.of<OrderProvider>(context, listen: false)
          .initShippingList(context, 1);
    }
    Provider.of<OrderProvider>(context, listen: false).getOrderDetails(
      orderId.toString(),
      context,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .countryCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadData(context);
    return Scaffold(
      backgroundColor: ColorResources.getIconBg(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(title: getTranslated('ORDER_DETAILS', context)),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, order, child) {
                List<int> sellerList = [];
                List<List<OrderDetailsModel>> sellerProductList = [];
                double _order = 0;
                double _discount = 0;
                double eeDiscount = 0;
                double _tax = 0;
                String shippingPartner = '';
                double _shippingFee = 0;

                if (order.orderDetails != null) {
                  order.orderDetails.forEach((orderDetails) {
                    if (!sellerList
                        .contains(orderDetails.productDetails.userId)) {
                      sellerList.add(orderDetails.productDetails.userId);
                    }
                  });
                  sellerList.forEach((seller) {
                    Provider.of<SellerProvider>(context, listen: false)
                        .initSeller(seller.toString(), context);
                    List<OrderDetailsModel> orderList = [];
                    order.orderDetails.forEach((orderDetails) {
                      if (seller == orderDetails.productDetails.userId) {
                        orderList.add(orderDetails);
                      }
                    });
                    sellerProductList.add(orderList);
                  });

                  order.orderDetails.forEach((orderDetails) {
                    _order = _order + (orderDetails.price * orderDetails.qty);
                    _discount = _discount + orderDetails.discount;
                    _tax = _tax + orderDetails.tax;
                  });

                  if (orderType == 'POS') {
                    if (extraDiscountType == 'percent') {
                      eeDiscount = _order * (extraDiscount / 100);
                    } else {
                      eeDiscount = extraDiscount;
                    }
                  }

                  if (order.shippingList != null) {
                    order.shippingList.forEach((shipping) {
                      if (shipping.id == order.trackingModel.shippingMethodId) {
                        shippingPartner = shipping.title;
                        _shippingFee = shipping.cost;
                      }
                    });
                  }
                }

                return order.orderDetails != null
                    ? ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(0),
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                horizontal: Dimensions.PADDING_SIZE_SMALL),
                            child: Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: getTranslated(
                                              'ORDER_ID', context),
                                          style: titilliumRegular.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_SMALL,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .color,
                                          )),
                                      TextSpan(
                                          text:
                                              order.trackingModel.id.toString(),
                                          style: titilliumSemiBold.copyWith(
                                              color: ColorResources.getPrimary(
                                                  context))),
                                    ],
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                Text(
                                    DateConverter.localDateToIsoStringAMPM(
                                        DateTime.parse(
                                            order.trackingModel.createdAt)),
                                    style: titilliumRegular.copyWith(
                                        color: ColorResources.getTextTitle(
                                            context),
                                        fontSize: Dimensions.FONT_SIZE_SMALL)),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.MARGIN_SIZE_SMALL),
                            decoration: BoxDecoration(
                                color: Theme.of(context).highlightColor),
                            child: Column(
                              children: [
                                orderType == 'POS'
                                    ? Text(getTranslated('pos_order', context))
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            Text(
                                                '${getTranslated('SHIPPING_TO', context)} : ',
                                                style: titilliumRegular),
                                            Expanded(
                                                child: Text(
                                                    ' ${orderModel != null && orderModel.shippingAddressData != null ? orderModel.shippingAddressData.address : ''}',
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: titilliumRegular
                                                        .copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_SMALL))),
                                          ]),
                                orderModel != null &&
                                        orderModel.billingAddressData != null
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${getTranslated('billing_address', context)} :',
                                              style: titilliumRegular),
                                          Expanded(
                                              child: Text(
                                                  ' ${orderModel.billingAddressData != null ? orderModel.billingAddressData.address : ''}',
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      titilliumRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_SMALL))),
                                        ],
                                      )
                                    : SizedBox(),

                                Divider(),
                                // orderType == "POS"? SizedBox():
                                // Row(children: [
                                //   Expanded(
                                //       child: Text(getTranslated('chosen_shipping', context), style: titilliumRegular)),
                                //   Text(shippingPartner, style: titilliumSemiBold.copyWith(color: ColorResources.getPrimary(context))),
                                // ]),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),
                          orderModel != null && orderModel.orderNote != null
                              ? Padding(
                                  padding: EdgeInsets.all(
                                      Dimensions.MARGIN_SIZE_SMALL),
                                  child: Text(
                                      '${getTranslated('order_note', context)} : ${orderModel.orderNote != null ? orderModel.orderNote ?? '' : ""}',
                                      style: titilliumRegular),
                                )
                              : SizedBox(),

                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),

                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            color: Theme.of(context).highlightColor,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      getTranslated('ORDERED_PRODUCT', context),
                                      style: robotoBold.copyWith(
                                          color: Theme.of(context).hintColor)),
                                  Divider(),
                                ]),
                          ),

                          ListView.builder(
                            itemCount: sellerList.length,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.MARGIN_SIZE_EXTRA_LARGE,
                                    vertical: Dimensions.MARGIN_SIZE_SMALL),
                                color: Theme.of(context).highlightColor,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (Provider.of<SellerProvider>(
                                                          context,
                                                          listen: false)
                                                      .orderSellerList
                                                      .length !=
                                                  0 &&
                                              sellerList[index] != 1) {
                                            Navigator.push(context,
                                                MaterialPageRoute(builder: (_) {
                                              return SellerScreen(
                                                  seller: Provider.of<
                                                              SellerProvider>(
                                                          context,
                                                          listen: false)
                                                      .orderSellerList[index]);
                                            }));
                                          }
                                        },
                                        child: Row(children: [
                                          Expanded(
                                              child: Text(
                                                  getTranslated(
                                                      'seller', context),
                                                  style: robotoBold)),
                                          Text(
                                            sellerList[index] == 1
                                                ? 'Admin'
                                                : Provider.of<SellerProvider>(
                                                                context)
                                                            .orderSellerList
                                                            .length <
                                                        index + 1
                                                    ? sellerList[index]
                                                        .toString()
                                                    : '${Provider.of<SellerProvider>(context).orderSellerList[index].seller.fName} '
                                                        '${Provider.of<SellerProvider>(context).orderSellerList[index].seller.lName}',
                                            style: titilliumRegular.copyWith(
                                                color: ColorResources
                                                    .HINT_TEXT_COLOR),
                                          ),
                                          SizedBox(
                                              width: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          Icon(Icons.chat,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 20),
                                        ]),
                                      ),
                                      // Text(getTranslated('ORDERED_PRODUCT', context), style: robotoBold.copyWith(color: ColorResources.HINT_TEXT_COLOR)),
                                      Divider(),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
                                        itemCount:
                                            sellerProductList[index].length,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i) =>
                                            OrderDetailsWidget(
                                          orderDetailsModel:
                                              sellerProductList[index][i],
                                          callback: () {
                                            showCustomSnackBar(
                                                'Review submitted successfully',
                                                context,
                                                isError: false);
                                          },
                                          orderType: orderType,
                                        ),
                                      ),
                                    ]),
                              );
                            },
                          ),
                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),

                          // Amounts
                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            color: Theme.of(context).highlightColor,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleRow(
                                      title: getTranslated('TOTAL', context)),
                                  AmountWidget(
                                      title: getTranslated('ORDER', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _order)),
                                  orderType == "POS"
                                      ? SizedBox()
                                      : AmountWidget(
                                          title: getTranslated(
                                              'SHIPPING_FEE', context),
                                          amount: PriceConverter.convertPrice(
                                              context,
                                              order
                                                  .trackingModel.shippingCost)),
                                  AmountWidget(
                                      title: getTranslated('DISCOUNT', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _discount)),
                                  orderType == "POS"
                                      ? AmountWidget(
                                          title: getTranslated(
                                              'EXTRA_DISCOUNT', context),
                                          amount: PriceConverter.convertPrice(
                                              context, eeDiscount))
                                      : SizedBox(),
                                  AmountWidget(
                                    title: getTranslated(
                                        'coupon_voucher', context),
                                    amount: PriceConverter.convertPrice(context,
                                        order.trackingModel.discountAmount),
                                  ),
                                  AmountWidget(
                                      title: getTranslated('TAX', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _tax)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                    child: Divider(
                                        height: 2,
                                        color: ColorResources.HINT_TEXT_COLOR),
                                  ),
                                  AmountWidget(
                                    title:
                                        getTranslated('TOTAL_PAYABLE', context),
                                    amount: PriceConverter.convertPrice(
                                        context,
                                        (_order +
                                            _shippingFee +
                                            order.trackingModel.shippingCost -
                                            eeDiscount -
                                            _discount +
                                            _tax)),
                                  ),
                                ]),
                          ),
                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),

                          //delivery info
                          order.trackingModel.deliveryMan != null
                              ?
                              //inhouse deliveryman
                              Container(
                                  padding: EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_SMALL),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).highlightColor),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${getTranslated('shipping_info', context)}',
                                            style: robotoBold),
                                        SizedBox(
                                            height: Dimensions
                                                .MARGIN_SIZE_EXTRA_SMALL),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  '${getTranslated('delivery_man', context)} : ',
                                                  style:
                                                      titilliumRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_SMALL)),
                                              Text(
                                                (order.trackingModel
                                                            .deliveryMan !=
                                                        null)
                                                    ? '${order.trackingModel.deliveryMan.fName} ${order.trackingModel.deliveryMan.lName}'
                                                    : '',
                                                style:
                                                    titilliumRegular.copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_SMALL),
                                              ),
                                            ]),
                                      ]),
                                )
                              :
                              //third party
                              order.trackingModel.thirdPartyServiceName != null
                                  ? Container(
                                      padding: EdgeInsets.all(
                                          Dimensions.PADDING_SIZE_SMALL),
                                      decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).highlightColor),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${getTranslated('shipping_info', context)}',
                                                style: robotoBold),
                                            SizedBox(
                                                height: Dimensions
                                                    .MARGIN_SIZE_EXTRA_SMALL),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      '${getTranslated('delivery_service_name', context)} : ',
                                                      style: titilliumRegular
                                                          .copyWith(
                                                              fontSize: Dimensions
                                                                  .FONT_SIZE_SMALL)),
                                                  Text(
                                                    (order.trackingModel
                                                                    .thirdPartyServiceName !=
                                                                null &&
                                                            order
                                                                .trackingModel
                                                                .thirdPartyServiceName
                                                                .isNotEmpty)
                                                        ? order.trackingModel
                                                            .thirdPartyServiceName
                                                        : '',
                                                    style: titilliumRegular
                                                        .copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_SMALL),
                                                  ),
                                                ]),
                                            SizedBox(
                                                height: Dimensions
                                                    .MARGIN_SIZE_EXTRA_SMALL),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      '${getTranslated('tracking_id', context)} : ',
                                                      style: titilliumRegular
                                                          .copyWith(
                                                              fontSize: Dimensions
                                                                  .FONT_SIZE_SMALL)),
                                                  Text(
                                                      order.trackingModel
                                                                  .thirdPartyTrackingId !=
                                                              null
                                                          ? order.trackingModel
                                                              .thirdPartyTrackingId
                                                          : '',
                                                      style: titilliumRegular
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_SMALL,
                                                      )),
                                                ]),
                                          ]),
                                    )
                                  : SizedBox(),

                          SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

                          // Payment
                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            decoration: BoxDecoration(
                                color: Theme.of(context).highlightColor),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(getTranslated('PAYMENT', context),
                                      style: robotoBold),
                                  SizedBox(
                                      height:
                                          Dimensions.MARGIN_SIZE_EXTRA_SMALL),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            getTranslated(
                                                'PAYMENT_STATUS', context),
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_SMALL)),
                                        Text(
                                          (order.trackingModel.paymentStatus !=
                                                      null &&
                                                  order.trackingModel
                                                      .paymentStatus.isNotEmpty)
                                              ? order.trackingModel
                                                          .paymentStatus ==
                                                      'paid'
                                                  ? 'Pagado'
                                                  : 'Sin pagar'
                                              : 'Digital Payment',
                                          style: titilliumRegular.copyWith(
                                              fontSize:
                                                  Dimensions.FONT_SIZE_SMALL),
                                        ),
                                      ]),
                                  SizedBox(
                                      height:
                                          Dimensions.MARGIN_SIZE_EXTRA_SMALL),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            getTranslated(
                                                'PAYMENT_PLATFORM', context),
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_SMALL)),
                                        Text(
                                            order.trackingModel.paymentMethod !=
                                                    null
                                                ? order
                                                    .trackingModel.paymentMethod
                                                    .replaceAll('_', ' ')
                                                : 'Digital Payment',
                                            style: titilliumBold.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )),
                                      ]),
                                ]),
                          ),

                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                          // Buttons
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_LARGE,
                                vertical: Dimensions.PADDING_SIZE_SMALL),
                            child: Row(
                              children: [
                                // Expanded(
                                //   child: orderModel != null &&
                                //           orderModel.orderStatus != 'pending' &&
                                //           orderType != "POS"
                                //       ? CustomButton(
                                //           buttonText: getTranslated(
                                //               'TRACK_ORDER', context),
                                //           onTap: () => Navigator.of(context)
                                //               .push(MaterialPageRoute(
                                //                   builder: (context) =>
                                //                       TrackingScreen(
                                //                           orderID: orderId
                                //                               .toString()))),
                                //         )
                                //       : SizedBox(),
                                // ),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                Expanded(
                                  child: SizedBox(
                                    height: 45,
                                    child: TextButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  SupportTicketScreen())),
                                      child: Text(
                                        getTranslated(
                                            'SUPPORT_CENTER', context),
                                        style: titilliumSemiBold.copyWith(
                                            fontSize: 16,
                                            color: ColorResources.getPrimary(
                                                context)),
                                      ),
                                      style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: BorderSide(
                                            color: ColorResources.getPrimary(
                                                context)),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : LoadingPage(); //Center(child: CustomLoader(color: Theme.of(context).primaryColor));
              },
            ),
          )
        ],
      ),
    );
  }
}
