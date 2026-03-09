import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewModel/bloc/auth_state/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return
                IconButton(onPressed: (){
                  context.read<AuthBloc>().add(AuthLogOut());
                }, icon: Icon(Icons.logout));
            }
          )
        ],
      ),
    );
  }
}
