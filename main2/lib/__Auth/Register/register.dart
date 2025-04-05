import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:main2/__About/PolicyWebViewPage.dart';
import 'package:main2/__Utils/NoNetwork/network_utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true; // Password visibility toggle
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize AnimationController and define slide animation.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // start below the screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Delay the animation a bit and then forward it.
    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPoliciesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Terms, Privacy, and Refund Policy"),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                const TextSpan(text: "By clicking continue, you agree to our "),
                _policyLink(context, "Terms and Conditions",
                    "assets/docs/Terms And Conditions.htm"),
                const TextSpan(text: ", "),
                _policyLink(context, "Privacy Policy",
                    "assets/docs/Privacy Policy.htm"),
                const TextSpan(text: ", and "),
                _policyLink(
                    context, "Refund Policy", "assets/docs/Refund Policy.htm"),
                const TextSpan(
                    text: ". Please review these before proceeding."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _registerUser(context);
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  TextSpan _policyLink(BuildContext context, String title, String assetPath) {
    return TextSpan(
      text: title,
      style: const TextStyle(
          color: Colors.blue, decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      PolicyPage(title: title, assetPath: assetPath)));
        },
    );
  }

  void _registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          await user.sendEmailVerification();
          await _firestore.collection('Users').doc(user.uid).set({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'emailVerified': false,
          });

          await _auth.signOut();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Account created! Verify your email before logging in.')),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Registration Failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack allows the background image and form to overlap.
      body: Stack(
        children: [
          _buildBackground(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildFormCard(),
            ),
          ),
        ],
      ),
    );
  }

  // Background set to img.jpg
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/3d-rendering-abstract-black-white-background_23-2150913897.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Card containing the registration form.
  Widget _buildFormCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameController, 'Name', Icons.person),
                const SizedBox(height: 16),
                _buildTextField(emailController, 'Email', Icons.email,
                    isEmail: true),
                const SizedBox(height: 16),
                _buildTextField(passwordController, 'Password', Icons.lock,
                    isPassword: true),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                const SizedBox(height: 16),
                _buildLoginRedirect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build a text field for the given controller, label, and icon.
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.red),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.red),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.red),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
      ),
      obscureText: isPassword ? _isObscure : false,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your $label';
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
          return 'Enter a valid email';
        if (isPassword && value.length < 6)
          return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  // Build the REGISTER button.
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        NetworkUtils.checkAndProceed(context, () {
          _showPoliciesDialog(context);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('REGISTER',
          style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }

  // Build the redirect button to go back to the login page.
  Widget _buildLoginRedirect() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Already have an account? Login',
          style: TextStyle(color: Colors.red)),
    );
  }
}
