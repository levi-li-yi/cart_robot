/*
 * @Author: Levi Li
 * @Date: 2024-03-13 11:08:52
 * @description: 
 */
import 'package:cart/bloc/setting/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cart/bloc/user/user_bloc.dart';

import 'package:scene/scene.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    _getUserList();
  }

  _getUserList() {
    BlocProvider.of<UserBloc>(context).add(
      GetUserListEvent(1, 10),
    );
  }

  // 监听用户列表数据
  void _listener(BuildContext context, UserState state) {
    print('_listener user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // child: BlocConsumer<UserBloc, UserState>(
        //   listener: _listener,
        //   builder: (context, state) {
        //     return ListView.builder(
        //       itemCount: state.dataList!.length,
        //       itemBuilder: (context, index) {
        //         return ListTile(title: Text(state.dataList![index].name));
        //       },
        //     );
        //   },
        // ),
        child: ElevatedButton(
          child: const Text('切换主题'),
          onPressed: () {
            final currentTheme = context.read<SettingBloc>().state.theme;
            context.read<SettingBloc>().add(ThemeChangedEvent(
                theme: currentTheme == 'light' ? 'dark' : 'light'));
          },
        ),
      ),
    );
  }
}
