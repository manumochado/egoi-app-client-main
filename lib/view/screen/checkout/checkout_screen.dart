import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/body/order_place_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/coupon_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/order_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/product_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/amount_widget.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/animated_custom_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/custom_app_bar.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/my_dialog.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/textfield/custom_textfield.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/title_row.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/address/add_new_address_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/address/saved_address_list_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/address/saved_billing_Address_list_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/checkout/widget/custom_check_box.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/create/client_payments_create_page.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/installments/client_payments_installments_controller.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/payment/payment_screen.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> cartList;
  final bool fromProductDetails;
  final double totalOrderAmount;
  final double shippingFee;
  final double discount;
  final double tax;
  final int sellerId;

  CheckoutScreen(
      {@required this.cartList,
      this.fromProductDetails = false,
      @required this.discount,
      @required this.tax,
      @required this.totalOrderAmount,
      @required this.shippingFee,
      this.sellerId});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _orderNoteController = TextEditingController();
  ClientPaymentsInstallmentsController _cClientPayments =
      new ClientPaymentsInstallmentsController();
  final FocusNode _orderNoteNode = FocusNode();
  double _order = 0;
  bool _digitalPayment;
  bool _cod;
  bool _efecty;
  bool _baloto;
  String email;
  String description;
  var concatenate = StringBuffer();
  List<String> list = [];

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);

    Provider.of<ProfileProvider>(context, listen: false)
        .initAddressList(context);
    Provider.of<ProfileProvider>(context, listen: false)
        .initAddressTypeList(context);
    Provider.of<CouponProvider>(context, listen: false).removePrevCouponData();
    Provider.of<CartProvider>(context, listen: false).getCartDataAPI(context);
    Provider.of<CartProvider>(context, listen: false)
        .getChosenShippingMethod(context);
    _digitalPayment = Provider.of<SplashProvider>(context, listen: false)
        .configModel
        .digitalPayment;
    _cod = Provider.of<SplashProvider>(context, listen: false).configModel.cod;
    _baloto = true;
    _efecty = true;

    // Provider.of<OrderProvider>(context, listen: false).shippingAddressNull();
    // Provider.of<OrderProvider>(context, listen: false).billingAddressNull();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _cClientPayments.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    _order = widget.totalOrderAmount + widget.discount;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      bottomNavigationBar: Container(
        height: 60,
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_LARGE,
            vertical: Dimensions.PADDING_SIZE_DEFAULT),
        decoration: BoxDecoration(
            color: ColorResources.getPrimary(context),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: Consumer<OrderProvider>(
          builder: (context, order, child) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<CouponProvider>(builder: (context, coupon, child) {
                    double _couponDiscount =
                        coupon.discount != null ? coupon.discount : 0;
                    return Text(
                      PriceConverter.convertPrice(
                          context,
                          (widget.totalOrderAmount +
                              widget.shippingFee +
                              widget.tax -
                              _couponDiscount)),
                      style: titilliumSemiBold.copyWith(
                          color: Theme.of(context).highlightColor),
                    );
                  }),
                  !Provider.of<OrderProvider>(context).isLoading
                      ? Builder(
                          builder: (context) => TextButton(
                            onPressed: () async {
                              
                              if (Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .addressIndex ==
                                  null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(getTranslated(
                                            'select_a_shipping_address',
                                            context)),
                                        backgroundColor: Colors.red));
                              } else {
                                List<CartModel> _cartList = [];
                                _cartList.addAll(widget.cartList);

                                for (int index = 0;
                                    index < widget.cartList.length;
                                    index++) {
                                  for (int i = 0;
                                      i <
                                          Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .chosenShippingList
                                              .length;
                                      i++) {
                                    if (Provider.of<CartProvider>(context,
                                                listen: false)
                                            .chosenShippingList[i]
                                            .cartGroupId ==
                                        widget.cartList[index].cartGroupId) {
                                      _cartList[index].shippingMethodId =
                                          Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .chosenShippingList[i]
                                              .id;
                                      break;
                                    }
                                  }
                                }

                                String orderNote =
                                    _orderNoteController.text.trim();
                                double couponDiscount =
                                    Provider.of<CouponProvider>(context,
                                                    listen: false)
                                                .discount !=
                                            null
                                        ? Provider.of<CouponProvider>(context,
                                                listen: false)
                                            .discount
                                        : 0;
                                String couponCode = Provider.of<CouponProvider>(
                                                context,
                                                listen: false)
                                            .discount !=
                                        null
                                    ? Provider.of<CouponProvider>(context,
                                            listen: false)
                                        .coupon
                                        .code
                                    : '';
                                    _cartList.forEach((element) {
                                    
                                    list.add(element.name);
                                  });
                                if (_cod &&
                                    Provider.of<OrderProvider>(context,
                                                listen: false)
                                            .paymentMethodIndex ==
                                        0) {
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .placeOrder(
                                          OrderPlaceModel(
                                            CustomerInfo(
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .id
                                                    .toString(),
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .address,
                                                orderNote),
                                            _cartList,
                                            order.paymentMethodIndex == 0
                                                ? 'cash_on_delivery'
                                                : 'efecty',
                                            couponDiscount,
                                          ),
                                          _callback,
                                          _cartList,
                                          Provider.of<ProfileProvider>(context,
                                                  listen: false)
                                              .addressList[
                                                  Provider.of<OrderProvider>(
                                                          context,
                                                          listen: false)
                                                      .addressIndex]
                                              .id
                                              .toString(),
                                          couponCode,
                                          orderNote);
                                } else if (Provider.of<OrderProvider>(context,
                                            listen: false)
                                        .paymentMethodIndex ==
                                    1) {
                                  double _couponDiscount =
                                      Provider.of<CouponProvider>(context,
                                                      listen: false)
                                                  .discount !=
                                              null
                                          ? Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .discount
                                          : 0;
                                  String userID =
                                      await Provider.of<ProfileProvider>(
                                              context,
                                              listen: false)
                                          .getUserInfo(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ClientPaymentsCreatePage(
                                                totalToPay: _order +
                                                    widget.shippingFee -
                                                    widget.discount -
                                                    _couponDiscount +
                                                    widget.tax,
                                              )
                                          // PaymentScreen(
                                          //   customerID: userID, addressID: Provider.of<ProfileProvider>(context, listen: false).addressList[Provider.of<OrderProvider>(context, listen: false).addressIndex].id.toString(),
                                          //   couponCode: Provider.of<CouponProvider>(context, listen: false).discount != null ? Provider.of<CouponProvider>(context, listen: false).coupon.code : '',
                                          //   billingId: Provider.of<ProfileProvider>(context, listen: false).billingAddressList[Provider.of<OrderProvider>(context, listen: false).billingAddressIndex].id.toString(),
                                          //   orderNote: orderNote,

                                          // )
                                          ));
                                } else if (Provider.of<OrderProvider>(context,
                                            listen: false)
                                        .paymentMethodIndex ==
                                    2) {
                                  double _couponDiscount =
                                      Provider.of<CouponProvider>(context,
                                                      listen: false)
                                                  .discount !=
                                              null
                                          ? Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .discount
                                          : 0;
                                  _cClientPayments.createPayEfecty(
                                      _order +
                                          widget.shippingFee -
                                          widget.discount -
                                          _couponDiscount +
                                          widget.tax,
                                      Provider.of<ProfileProvider>(context,
                                              listen: false)
                                          .userInfoModel
                                          .email, list.join(", "));
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .placeOrderEfecty(
                                          OrderPlaceModel(
                                            CustomerInfo(
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .id
                                                    .toString(),
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .address,
                                                orderNote),
                                            _cartList,
                                            order.paymentMethodIndex == 2
                                                ? 'efecty'
                                                : 'baloto',
                                            couponDiscount,
                                          ),
                                          _callback,
                                          _cartList,
                                          Provider.of<ProfileProvider>(context,
                                                  listen: false)
                                              .addressList[
                                                  Provider.of<OrderProvider>(
                                                          context,
                                                          listen: false)
                                                      .addressIndex]
                                              .id
                                              .toString(),
                                          couponCode,
                                          orderNote);
                                  // Navigator.of(context).pushAndRemoveUntil(
                                  //     MaterialPageRoute(builder: (context) {
                                  //   return DashBoardScreen();
                                  // }), (route) => false);
                                } else if (Provider.of<OrderProvider>(context,
                                            listen: false)
                                        .paymentMethodIndex ==
                                    3) {
                                  
                                  
                                  double _couponDiscount =
                                      Provider.of<CouponProvider>(context,
                                                      listen: false)
                                                  .discount !=
                                              null
                                          ? Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .discount
                                          : 0;
                                  _cClientPayments.createPayBaloto(
                                      _order +
                                          widget.shippingFee -
                                          widget.discount -
                                          _couponDiscount +
                                          widget.tax,
                                      Provider.of<ProfileProvider>(context,
                                              listen: false)
                                          .userInfoModel
                                          .email,
                                      list.join(", "));
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .placeOrderBaloto(
                                          OrderPlaceModel(
                                            CustomerInfo(
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .id
                                                    .toString(),
                                                Provider.of<ProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .addressList[Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false)
                                                        .addressIndex]
                                                    .address,
                                                orderNote),
                                            _cartList,
                                            order.paymentMethodIndex == 2
                                                ? 'baloto'
                                                : '',
                                            couponDiscount,
                                          ),
                                          _callback,
                                          _cartList,
                                          Provider.of<ProfileProvider>(context,
                                                  listen: false)
                                              .addressList[
                                                  Provider.of<OrderProvider>(
                                                          context,
                                                          listen: false)
                                                      .addressIndex]
                                              .id
                                              .toString(),
                                          couponCode,
                                          orderNote);
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).highlightColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Confirmar',
                                style: titilliumSemiBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                                  color: ColorResources.getPrimary(context),
                                )),
                          ),
                        )
                      : Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).highlightColor)),
                        ),
                ]);
          },
        ),
      ),
      body: Column(
        children: [
          CustomAppBar(title: getTranslated('checkout', context)),
          Expanded(
            child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(0),
                children: [
                  // Shipping Details
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration:
                        BoxDecoration(color: Theme.of(context).highlightColor),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Enviar a: ',
                              style: titilliumRegular.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.04)),
                          Expanded(
                            child: Text(
                              Provider.of<OrderProvider>(context, listen: false)
                                          .addressIndex ==
                                      null
                                  ? 'Agrega una dirección'
                                  : Provider.of<ProfileProvider>(context,
                                          listen: false)
                                      .addressList[Provider.of<OrderProvider>(
                                              context,
                                              listen: false)
                                          .addressIndex]
                                      .address,
                              style: titilliumRegular.copyWith(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          // InkWell(
                          //   onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddNewAddressScreen(isBilling: false))),
                          //   child: Container(
                          //       decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                          //           color: ColorResources.getPrimary(context)),
                          //       child: Icon(Icons.add, size: 30, color: Theme.of(context).cardColor)),
                          // ),
                          SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SavedAddressListScreen()))
                                  .then((value) {
                                setState(() {});
                              });
                            },
                            child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                                width:
                                    MediaQuery.of(context).size.height * 0.03,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: ColorResources.getPrimary(context)),
                                child: Icon(Icons.edit,
                                    size: MediaQuery.of(context).size.height *
                                        0.022,
                                    color: Theme.of(context).cardColor)),
                          ),
                        ],
                      ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text(
                      //         '${getTranslated('billing_address', context)} : ',
                      //         style: titilliumRegular.copyWith(
                      //             fontWeight: FontWeight.w600)),
                      //     Expanded(
                      //       child: Text(
                      //         Provider.of<OrderProvider>(context)
                      //                     .billingAddressIndex ==
                      //                 null
                      //             ? getTranslated('add_your_address', context)
                      //             : Provider.of<ProfileProvider>(context,
                      //                     listen: false)
                      //                 .billingAddressList[
                      //                     Provider.of<OrderProvider>(context,
                      //                             listen: false)
                      //                         .billingAddressIndex]
                      //                 .address,
                      //         style: titilliumRegular.copyWith(
                      //             fontSize: Dimensions.FONT_SIZE_SMALL),
                      //         maxLines: 3,
                      //         overflow: TextOverflow.fade,
                      //       ),
                      //     ),
                      //     // InkWell(
                      //     //   onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddNewAddressScreen(isBilling: true))),
                      //     //   child: Container(
                      //     //       decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      //     //           color: ColorResources.getPrimary(context)),
                      //     //       child: Icon(Icons.add, size: 15, color: Theme.of(context).cardColor)),
                      //     // ),
                      //     SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                      //     InkWell(
                      //       onTap: () => Navigator.of(context).push(
                      //           MaterialPageRoute(
                      //               builder: (BuildContext context) =>
                      //                   SavedBillingAddressListScreen())),
                      //       child: Container(
                      //           decoration: BoxDecoration(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(20)),
                      //               color: ColorResources.getPrimary(context)),
                      //           child: Padding(
                      //             padding: const EdgeInsets.all(5),
                      //             child: Icon(Icons.edit,
                      //                 size: 15,
                      //                 color: Theme.of(context).cardColor),
                      //           )),
                      //     ),
                      //   ],
                      // ),
                    ]),
                  ),

                  // Order Details
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleRow(title: 'Detalles de tu pedido'),
                          ConstrainedBox(
                            constraints: Provider.of<CartProvider>(context,
                                            listen: false)
                                        .cartList
                                        .length >
                                    0
                                ? BoxConstraints(
                                    maxHeight: 90 *
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .cartList
                                            .length
                                            .toDouble())
                                : BoxConstraints(maxHeight: 0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: Provider.of<CartProvider>(context,
                                        listen: false)
                                    .cartList
                                    .length,
                                itemBuilder: (ctx, index) {
                                  return Padding(
                                    padding: EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    child: Row(children: [
                                      FadeInImage.assetNetwork(
                                        placeholder: Images.placeholder,
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        image:
                                            '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productThumbnailUrl}/${Provider.of<CartProvider>(context, listen: false).cartList[index].thumbnail}',
                                        imageErrorBuilder: (c, o, s) =>
                                            Image.asset(Images.placeholder,
                                                fit: BoxFit.cover,
                                                width: 50,
                                                height: 50),
                                      ),
                                      SizedBox(
                                          width:
                                              Dimensions.MARGIN_SIZE_DEFAULT),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Provider.of<CartProvider>(
                                                        context,
                                                        listen: false)
                                                    .cartList[index]
                                                    .name,
                                                style: titilliumRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .FONT_SIZE_EXTRA_SMALL,
                                                    color: ColorResources
                                                        .getPrimary(context)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(
                                                  height: Dimensions
                                                      .MARGIN_SIZE_EXTRA_SMALL),
                                              Row(children: [
                                                Text(
                                                  PriceConverter.convertPrice(
                                                      context,
                                                      Provider.of<CartProvider>(
                                                              context,
                                                              listen: false)
                                                          .cartList[index]
                                                          .price),
                                                  style: titilliumSemiBold
                                                      .copyWith(
                                                          color: ColorResources
                                                              .getPrimary(
                                                                  context)),
                                                ),
                                                SizedBox(
                                                    width: Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                Text(
                                                    Provider.of<CartProvider>(
                                                            context,
                                                            listen: false)
                                                        .cartList[index]
                                                        .quantity
                                                        .toString(),
                                                    style: titilliumSemiBold
                                                        .copyWith(
                                                            color: ColorResources
                                                                .getPrimary(
                                                                    context))),
                                                Provider.of<CartProvider>(
                                                                context,
                                                                listen: false)
                                                            .cartList[index]
                                                            .discount >
                                                        0
                                                    ? Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal: Dimensions
                                                                .PADDING_SIZE_EXTRA_SMALL),
                                                        margin: EdgeInsets.only(
                                                            left: Dimensions
                                                                .MARGIN_SIZE_EXTRA_LARGE),
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            border: Border.all(
                                                                color: ColorResources
                                                                    .getPrimary(
                                                                        context))),
                                                        child: Text(
                                                          PriceConverter.percentageCalculation(
                                                              context,
                                                              Provider.of<CartProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .cartList[
                                                                      index]
                                                                  .price,
                                                              Provider.of<CartProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .cartList[
                                                                      index]
                                                                  .discount,
                                                              Provider.of<CartProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .cartList[
                                                                      index]
                                                                  .discountType),
                                                          style: titilliumRegular.copyWith(
                                                              fontSize: Dimensions
                                                                  .FONT_SIZE_EXTRA_SMALL,
                                                              color: ColorResources
                                                                  .getPrimary(
                                                                      context)),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ]),
                                            ]),
                                      ),
                                    ]),
                                  );
                                }),
                          ),

                          // Coupon
                          Row(children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                    controller: _controller,
                                    decoration: InputDecoration(
                                      hintText: '¿Tienes un cupón?',
                                      hintStyle: titilliumRegular.copyWith(
                                          color:
                                              ColorResources.HINT_TEXT_COLOR),
                                      filled: true,
                                      fillColor:
                                          ColorResources.getIconBg(context),
                                      border: InputBorder.none,
                                    )),
                              ),
                            ),
                            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                            !Provider.of<CouponProvider>(context).isLoading
                                ? ElevatedButton(
                                    onPressed: () {
                                      if (_controller.text.isNotEmpty) {
                                        Provider.of<CouponProvider>(context,
                                                listen: false)
                                            .initCoupon(
                                                _controller.text, _order)
                                            .then((value) {
                                          if (value > 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Tienes ${PriceConverter.convertPrice(context, value)} de descuento'),
                                                    backgroundColor:
                                                        Colors.green));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(getTranslated(
                                                  'invalid_coupon_or',
                                                  context)),
                                              backgroundColor: Colors.red,
                                            ));
                                          }
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: ColorResources.getGreen(context),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text('Aplicar'),
                                  )
                                : CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor)),
                          ]),
                        ]),
                  ),

                  // Total bill
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Consumer<OrderProvider>(
                      builder: (context, order, child) {
                        //_shippingCost = order.shippingIndex != null ? order.shippingList[order.shippingIndex].cost : 0;
                        double _couponDiscount =
                            Provider.of<CouponProvider>(context).discount !=
                                    null
                                ? Provider.of<CouponProvider>(context).discount
                                : 0;

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleRow(title: 'Factura'),
                              AmountWidget(
                                  title: 'En productos',
                                  amount: PriceConverter.convertPrice(
                                      context, _order)),
                              AmountWidget(
                                  title: 'Costo de envío',
                                  amount: PriceConverter.convertPrice(
                                      context, widget.shippingFee)),
                              AmountWidget(
                                  title: 'Descuento',
                                  amount: PriceConverter.convertPrice(
                                      context, widget.discount)),
                              AmountWidget(
                                  title: 'Cupón',
                                  amount: PriceConverter.convertPrice(
                                      context, _couponDiscount)),
                              AmountWidget(
                                  title: 'Impuesto',
                                  amount: PriceConverter.convertPrice(
                                      context, widget.tax)),
                              Divider(
                                  height: 5,
                                  color: Theme.of(context).hintColor),
                              AmountWidget(
                                  title: 'Total a pagar',
                                  amount: PriceConverter.convertPrice(
                                      context,
                                      (_order +
                                          widget.shippingFee -
                                          widget.discount -
                                          _couponDiscount +
                                          widget.tax))),
                            ]);
                      },
                    ),
                  ),

                  // Payment Method
                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      TitleRow(title: 'Métodos de pago'),
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(
                  'Tu pedido tardará de 3 a 4 días hábiles en llegar a tu domicilio.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),)),
                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                      _order >= 30000
                          ? _cod
                              ? CustomCheckBox(
                                  title: 'Pago contra entrega', index: 0)
                              : SizedBox()
                          : SizedBox(),
                     _order == 5600125307
                          ? _digitalPayment
                          ? CustomCheckBox(title: 'Pagar con tarjeta', index: 1)
                          : SizedBox() : SizedBox(),
                      _order >= 5000 && _order <= 8000000
                          ? _efecty
                              ? CustomCheckBox(
                                  title: 'Pagar por Efecty', index: 2)
                              : SizedBox()
                          : SizedBox(),
                      _order >= 1000 && _order <= 1000000
                          ? _baloto
                              ? CustomCheckBox(
                                  title: 'Pagar por Baloto', index: 3)
                              : SizedBox()
                          : SizedBox(),
                    ]),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                    padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                    color: Theme.of(context).highlightColor,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated('order_note', context),
                            style: robotoRegular.copyWith(
                                color: ColorResources.getHint(context)),
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          CustomTextField(
                            hintText: getTranslated('enter_note', context),
                            textInputType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            focusNode: _orderNoteNode,
                            controller: _orderNoteController,
                          ),
                        ]),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  void _callback(bool isSuccess, String message, String orderID,
      List<CartModel> carts) async {
    if (isSuccess) {
      Provider.of<ProductProvider>(context, listen: false).getLatestProductList(
        1,
        context,
        reload: true,
      );
      if (Provider.of<OrderProvider>(context, listen: false)
              .paymentMethodIndex ==
          0) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => DashBoardScreen()),
            (route) => false);
        showAnimatedDialog(
            context,
            MyDialog(
              icon: Icons.check,
              title: '¡Pedido realizado con éxito!',
              description: 'Tu pedido tardará de 3 a 4 hábiles días en llegar a tu domicilio.',
              isFailed: false,
            ),
            dismissible: false,
            isFlip: true);
      } else if (Provider.of<OrderProvider>(context, listen: false)
                  .paymentMethodIndex ==
              2 ||
          Provider.of<OrderProvider>(context, listen: false)
                  .paymentMethodIndex ==
              3) {
      } else {}
      Provider.of<OrderProvider>(context, listen: false).stopLoader();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: ColorResources.RED));
    }
  }

  void refresh() {
    setState(() {});
  }
}

class PaymentButton extends StatelessWidget {
  final String image;
  final Function onTap;
  PaymentButton({@required this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        margin: EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: ColorResources.getGrey(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(image),
      ),
    );
  }
}
