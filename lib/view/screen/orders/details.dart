import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/orders/details.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/core/functions/currency_formatter.dart';

class OrdersDetails extends StatelessWidget {
  const OrdersDetails({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OrdersDetailsController());
    return Scaffold(
      appBar: AppBar(title: const Text('Orders Details')),
      body: GetBuilder<OrdersDetailsController>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...controller.data.map(
                (item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemsNameEn ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        if ((item.cartItemColor ?? '').isNotEmpty ||
                            (item.cartItemSize ?? '').isNotEmpty)
                          Text(
                            'Color: ${item.cartItemColor ?? '-'} | Size: ${item.cartItemSize ?? '-'}',
                          ),
                        if ((item.cartLensName ?? '').isNotEmpty)
                          Text('Lens: ${item.cartLensName}'),
                        if ((item.cartPrescriptionSummary ?? '').isNotEmpty)
                          Text(
                            item.cartPrescriptionSummary!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        const SizedBox(height: 8),
                        Text('Qty: ${item.countitems ?? '1'}'),
                        Text(
                          'Price: ${CurrencyFormatter.egp(double.tryParse(item.lineTotal ?? item.itemsPrice ?? '0') ?? 0)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Total Price: ${CurrencyFormatter.egp(double.tryParse(controller.ordersModel.ordersTotalprice ?? '0') ?? 0)}',
                    style: const TextStyle(
                      color: ColorApp.praimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (controller.ordersModel.ordersType == "0")
                Card(
                  child: ListTile(
                    title: const Text(
                      'Shipping Address',
                      style: TextStyle(
                        color: ColorApp.praimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${controller.ordersModel.addressCity ?? ''} ${controller.ordersModel.addressStreet ?? ''}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
