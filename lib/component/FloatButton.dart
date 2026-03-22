 import 'package:flutter/material.dart';

class FloatButton extends StatelessWidget {

  final VoidCallback onPressed;

  final Icon? icon;

  const FloatButton({super.key, required this.onPressed, this.icon});

  @override
   Widget build(BuildContext context) {
     return Container(
       width: 56,
       height: 56,
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(16),
         gradient: const LinearGradient(
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
           colors: [
             Color(0xFF002D1C),
             Color(0xFF00452E),
           ],
         ),
         boxShadow: const [
           BoxShadow(
             color: Color(0x1F1A1C1A),
             offset: Offset(0, 12),
             blurRadius: 32,
           ),
         ],
       ),
       child: IconButton(
           icon: icon??const Icon(
             Icons.add,
             color: Colors.white,
             size: 20,
           ),
           onPressed: onPressed),
     );
   }
 }
