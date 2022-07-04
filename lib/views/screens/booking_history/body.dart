import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sfbms_mobile/view_model/booking_viewmodel.dart';
import 'package:sfbms_mobile/view_model/user_viewmodel.dart';
import 'package:sfbms_mobile/views/screens/booking_history/widgets/booking_history_item.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  Future<bool?> _onRefresh({
    bool isRefresh = false,
    required BookingViewModel bookingVM,
    required UserViewModel userVM,
  }) async {
    var result = await bookingVM.getBookings(
      idToken: (await userVM.idToken)!,
      isRefresh: isRefresh,
    );

    if (result == null) return null;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: true);

    return Consumer2<UserViewModel, BookingViewModel>(
      builder: ((context, userVM, bookingVM, _) {
        return SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          controller: refreshController,
          onRefresh: () async {
            refreshController.resetNoData();
            var result = await _onRefresh(isRefresh: true, bookingVM: bookingVM, userVM: userVM);

            if (result!) {
              refreshController.refreshCompleted();
            } else {
              refreshController.loadFailed();
            }
          },
          onLoading: () async {
            final result = await _onRefresh(bookingVM: bookingVM, userVM: userVM);

            if (result == null) {
              refreshController.loadNoData();
            } else if (result) {
              refreshController.loadComplete();
            } else {
              refreshController.loadFailed();
            }
          },
          header: const WaterDropHeader(),
          footer: const ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
            completeDuration: Duration(milliseconds: 500),
          ),
          child: ListView.builder(
            itemCount: bookingVM.bookings.data?.bookings?.length ?? 0,
            itemBuilder: (context, index) {
              if (bookingVM.bookings.data == null) {
                return const Center(child: Text("No bookings found."));
              }
              return BookingHistoryItem(
                bookingID: bookingVM.bookings.data!.bookings![index].id!,
                bookingDate: bookingVM.bookings.data!.bookings![index].bookingDate!,
                numberOfFields: bookingVM.bookings.data!.bookings![index].numberOfFields!,
              );
            },
          ),
        );
      }),
    );
  }
}
