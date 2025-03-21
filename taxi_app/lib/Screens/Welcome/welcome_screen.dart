import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../components/background.dart';
import '../../__Core/constants.dart';
import '../../__Core/responsive.dart';
import 'components/login_signup_btn.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Responsive(
            desktop: _buildDesktopLayout(),
            mobile: _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: _buildWelcomeImage()),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 450,
              child: LoginAndSignupBtn(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWelcomeImage(),
        Row(
          children: const [
            Spacer(),
            Expanded(flex: 8, child: LoginAndSignupBtn()),
            Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeImage() {
    return Column(
      children: [
        const Text(
          "WELCOME",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset(
                "assets/icons/chat.svg",
                fit: BoxFit.fill,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
