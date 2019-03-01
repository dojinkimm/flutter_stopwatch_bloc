import 'package:flutter/material.dart';
import './bloc/bloc_provider.dart';
import './bloc/running_bloc.dart';
import './ui/app.dart';

void main() {
  runApp(
    BlocProvider<RunningBloc>(
      bloc: RunningBloc(), 
      child: RunApp()
    ));
}
