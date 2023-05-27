import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/common/user_info_model.dart';
import 'package:gpt_app/common/vip_charge.dart';
import 'package:gpt_app/manager/user_manager.dart';
import 'package:gpt_app/module/home/model/invite_code_model.dart';
import 'package:gpt_app/theme/theme_colors.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.inviteCodeModel});
  final InviteCodeModel? inviteCodeModel;
  @override
  State<ProfilePage> createState() => _ProfilePagetate();
}

class _ProfilePagetate extends State<ProfilePage> {
  UserInfoModel? infoModel;

  @override
  void initState() {
    super.initState();
    UserManager.getUserInfo().then((value) {
      setState(() {
        infoModel = value?.userInfo;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(children: _profileDetail()),
      ),
    );
  }

  List<Widget> _profileDetail() {
    final widgets = <Widget>[];
    if (infoModel != null) {
      final isVip = infoModel!.isVip;
      widgets.add(_buildCell("用户类型：", isVip ? "VIP 会员" : "免费用户"));
      if (isVip) {
        final endedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(infoModel!.vipEndedAt);
        widgets.add(_buildCell("会员到期：", endedDate));
      } else {
        widgets.add(_buildCell("免费消息剩余：", '${infoModel!.freeUsage}条'));
      }
    }

    widgets.add(SizedBox(
        height: 50,
        child: Column(children: [
          Row(
            children: [
              const Text('会员充值：'),
              const Spacer(),
              const Text("客服微信:$serviceWXId"),
              const Padding(padding: EdgeInsets.only(left: 10)),
              TextButton(
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: serviceWXId));
                    EasyLoading.showToast("已成功复制");
                  },
                  child: Row(
                    children: [
                      const Text('复制'),
                      Icon(
                        Icons.copy,
                        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                      )
                    ],
                  )),
            ],
          ),
          const Divider(
            thickness: 0.5,
            height: 0.5,
            color: cellLine,
          )
        ])));

    if (widget.inviteCodeModel != null) {
      widgets.add(SizedBox(
          height: 50,
          child: Column(children: [
            Row(
              children: [
                const Text('邀请码：'),
                const Spacer(),
                Text(widget.inviteCodeModel!.code),
                const Padding(padding: EdgeInsets.only(left: 10)),
                TextButton(
                    onPressed: () async {
                      await Clipboard.setData(const ClipboardData(text: serviceWXId));
                      EasyLoading.showToast("邀请码已成功复制");
                    },
                    child: Row(
                      children: [
                        const Text('复制'),
                        Icon(
                          Icons.copy,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                        )
                      ],
                    )),
              ],
            ),
            const Divider(
              thickness: 0.5,
              height: 0.5,
              color: cellLine,
            )
          ])));
    }
    return widgets;
  }

  Widget _buildCell(String title, content) {
    return SizedBox(
      height: 40,
      child: Column(children: [
        const Spacer(),
        Row(
          children: [Text(title), const Spacer(), Text(content)],
        ),
        const Spacer(),
        const Divider(
          thickness: 0.5,
          height: 0.5,
          color: cellLine,
        )
      ]),
    );
  }
}
