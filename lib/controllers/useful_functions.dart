import 'package:flutter/material.dart';

Route createRoute(Widget f){
  return PageRouteBuilder(
      transitionDuration: Duration(seconds: 1,),
      pageBuilder: (context,animation,secondaryAnimation) => f,
      transitionsBuilder: (context,animation,secondaryAnimation,child) {

        const begin = Offset(0.0,1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin,end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween),child: child,);
      }

  );
}