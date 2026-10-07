import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AppHeader({
    Key? key,
    this.title = 'Principal Scheduler',
    this.subtitle = 'Shri Shankarlal Sundarbai Shasun Jain College',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage('assets/college_logo.jpeg'),
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.nunitoSans(fontSize: 12, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
