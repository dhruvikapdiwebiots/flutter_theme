import '../../../../config.dart';

class ContactListTile extends StatelessWidget {
  final DocumentSnapshot? document;
  const ContactListTile({Key? key,this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   ListTile(
        isThreeLine: false,
        leading: CachedNetworkImage(
            imageUrl: document!['content'].split('-BREAK-')[2],
            imageBuilder: (context, imageProvider) =>
                CircleAvatar(
                  backgroundColor: const Color(0xffE6E6E6),
                  radius: 30,
                  backgroundImage: NetworkImage(
                      '${document!['content'].split('-BREAK-')[2]}'),
                ),
            placeholder: (context, url) => const CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: 30,
              child: Icon(
                Icons.people,
                color: Color(0xffCCCCCC),
              ),
            ),
            errorWidget: (context, url, error) =>
            const CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: 30,
              child: Icon(
                Icons.people,
                color: Color(0xffCCCCCC),
              ),
            )),
        title: Text(
          document!['content'].split('-BREAK-')[0],
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: appCtrl.appTheme.whiteColor),
        ),
        subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              document!['content'].split('-BREAK-')[1],
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: appCtrl.appTheme.accent),
            )));
  }
}
