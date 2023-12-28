

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../config.dart';

class AllContactPageList extends StatelessWidget {
  const AllContactPageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllContactListController>(
      builder: (contactCtrl) {
        return Expanded(
            child: RefreshIndicator(
                onRefresh: () => Future.sync(
                      () => contactCtrl.fetchPage(0, ""),
                ),
                child: PagedListView<int, Contact>(
                  pagingController: contactCtrl.pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Contact>(
                      noItemsFoundIndicatorBuilder: (_) => Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Center(
                              child:
                              const CircularProgressIndicator()
                                  .width(Sizes.s30)
                                  .height(Sizes.s30)),
                          Text(fonts.noItemFound.tr)
                              .alignment(Alignment.center)
                        ],
                      ),
                      itemBuilder: (context, item, index) =>
                          AllContactListCard(
                            index: index,
                            item: item,
                          ).width(MediaQuery.of(context).size.width)),
                )));
      }
    );
  }
}
