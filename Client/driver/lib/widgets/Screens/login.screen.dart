import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/providers/auth.provider.dart';
import 'package:transit_lanka/screens/auth/size_config.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:transit_lanka/shared/constants/styles.dart';
import 'package:transit_lanka/shared/widgets/animated_background.dart';
import 'package:transit_lanka/shared/widgets/animated_gif.dart';
import 'components/land.dart';
import 'components/sun.dart';
import 'components/tabs.dart';
import 'register.screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isFullSun = false;
  bool isDayMood = true;
  Duration _duration = Duration(seconds: 1);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'passenger'; // Default role
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isFullSun = true;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void changeMood(int activeTabNum) {
    if (activeTabNum == 0) {
      setState(() {
        isDayMood = true;
        _selectedRole = 'passenger';
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          isFullSun = true;
        });
      });
    } else {
      setState(() {
        isFullSun = false;
        _selectedRole = 'driver';
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          isDayMood = false;
        });
      });
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(_emailController.text.trim(),
          _passwordController.text, _selectedRole);

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(
            _selectedRole == 'driver' ? '/driver/home' : '/passenger/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final authProvider = Provider.of<AuthProvider>(context);

    List<Color> lightBgColors = [
      const Color.fromARGB(255, 203, 45, 45),
      const Color.fromARGB(255, 255, 149, 57),
      const Color.fromARGB(255, 189, 255, 124),
      if (isFullSun) AppColors.tertiaryLight,
    ];
    var darkBgColors = [
      Color(0xFF0D1441),
      AppColors.primaryDark,
      AppColors.secondary,
    ];

    return Scaffold(
      body: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeInOut,
        width: double.infinity,
        height: SizeConfig.screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDayMood ? lightBgColors : darkBgColors,
          ),
        ),
        child: Stack(
          children: [
            Sun(duration: _duration, isFullSun: isFullSun),
            Land(),

            // Bus animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.3, end: 1.2),
              duration: Duration(seconds: 5),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Positioned(
                  bottom: 60,
                  left: 200,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      scale: value,
                      child: Image.asset(
                        'assets/images/bus2.png',
                        width: 200,
                        height: 120,
                      ),
                    ),
                  ),
                );
              },
            ),

           Positioned(
              top: 130,
              right: _selectedRole == 'passenger' ? 30 : -100,
              child: AnimatedOpacity(
                opacity: _selectedRole == 'passenger' ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  transform: Matrix4.identity()
                    ..scale(_selectedRole == 'passenger' ? 1.0 : 0.5),
                  transformAlignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/boy.png',
                    width: 100,
                    height: 150,
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VerticalSpacing(of: 50),
                        Tabs(
                          press: (value) {
                            changeMood(value);
                          },
                        ),
                        VerticalSpacing(),
                        Text(
                          "Transit Lanka",
                          style: AppStyles.heading1
                              .copyWith(color: AppColors.textLight),
                        ),
                        VerticalSpacing(of: 10),
                        Text(
                          "Enter your credentials to login",
                          style: AppStyles.bodyText2
                              .copyWith(color: AppColors.textLight),
                        ),
                        VerticalSpacing(of: 50),
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        VerticalSpacing(),
                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          hintText: "Password",
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        VerticalSpacing(of: 30),
                        // Login button
                        ElevatedButton(
                          style: AppStyles.primaryButton,
                          onPressed: authProvider.isLoading ? null : _login,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            height: 50,
                            child: authProvider.isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text("LOGIN"),
                          ),
                        ),
                        // Error message
                        if (authProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              authProvider.error!,
                              style: TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        VerticalSpacing(of: 15),
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textLight),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/register');
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  color: AppColors.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        VerticalSpacing(of: 50), // Extra space for scrolling
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText,
          style: AppStyles.bodyText2
              .copyWith(color: AppColors.textLight.withOpacity(0.7)),
        ),
        VerticalSpacing(of: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 2,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: AppColors.textLight),
            keyboardType: keyboardType,
            obscureText: isPassword ? _obscurePassword : false,
            validator: validator,
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textLight.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class VerticalSpacing extends StatelessWidget {
  final double of;

  const VerticalSpacing({this.of = 20, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: of);
  }
}
