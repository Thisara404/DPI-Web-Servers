import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transit_lanka/core/providers/auth.provider.dart';
import 'package:transit_lanka/screens/auth/screens/components/land.dart';
import 'package:transit_lanka/screens/auth/screens/components/sun.dart';
import 'package:transit_lanka/screens/auth/size_config.dart';
import 'package:transit_lanka/shared/constants/colors.dart';
import 'package:transit_lanka/shared/constants/styles.dart';
import 'package:transit_lanka/shared/widgets/role_selection_card.dart';
import 'package:transit_lanka/shared/widgets/animated_background.dart';
import 'package:transit_lanka/shared/widgets/animated_gif.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isFullSun = false;
  bool isDayMood = true;
  Duration _duration = Duration(seconds: 1);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _workAddressController = TextEditingController();
  final _busNumberController = TextEditingController();
  final _busModelController = TextEditingController();
  final _busColorController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  String _selectedRole = 'passenger';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  int _currentStep = 0;
  bool _isLoading = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _workAddressController.dispose();
    _busNumberController.dispose();
    _busModelController.dispose();
    _busColorController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      Map<String, dynamic> additionalInfo;

      if (_selectedRole == 'passenger') {
        additionalInfo = {
          'addresses': {
            'home': _addressController.text.trim(),
            if (_workAddressController.text.isNotEmpty)
              'work': _workAddressController.text.trim(),
          }
        };
      } else {
        additionalInfo = {
          'address': _addressController.text.trim(),
          'licenseNumber': _licenseNumberController.text.trim(),
          'busDetails': {
            'busNumber': _busNumberController.text.trim(),
            'busModel': _busModelController.text.trim(),
            'busColor': _busColorController.text.trim(),
          }
        };
      }

      try {
        setState(() {
          _isLoading = true;
        });

        final user = await authProvider.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _phoneController.text.trim(),
          _passwordController.text,
          _selectedRole,
          additionalInfo: additionalInfo,
        );

        if (mounted) {
          if (_selectedRole == 'passenger') {
            Navigator.of(context).pushReplacementNamed('/passenger/home');
          } else {
            Navigator.of(context).pushReplacementNamed('/driver/home');
          }
        }
      } catch (e) {
        final errorMessage = e.toString().contains('Exception:')
            ? e.toString()
            : 'Registration failed: ${e.toString()}';

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.3, end: 1.0),
              duration: Duration(seconds: 2),
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
              top: 50,
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
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VerticalSpacing(of: 30),
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (_currentStep > 0) {
                              setState(() {
                                _currentStep--;
                              });
                            } else {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            }
                          },
                        ),
                        VerticalSpacing(of: 20),
                        Text(
                          "Transit Lanka",
                          style: AppStyles.heading1
                              .copyWith(color: AppColors.textLight),
                        ),
                        VerticalSpacing(of: 10),
                        Text(
                          "Create your account",
                          style: AppStyles.bodyText2
                              .copyWith(color: AppColors.textLight),
                        ),
                        VerticalSpacing(of: 30),
                        _buildRegistrationSteps(authProvider),
                        VerticalSpacing(of: 20),
                        if (authProvider.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              authProvider.error!,
                              style: TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: AppColors.textLight),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: AppColors.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        VerticalSpacing(of: 50),
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

  Widget _buildRegistrationSteps(AuthProvider authProvider) {
    switch (_currentStep) {
      case 0:
        return _buildRoleSelection();
      case 1:
        return _buildBasicInfoForm();
      case 2:
        return _buildRoleSpecificForm(authProvider);
      default:
        return Container();
    }
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Account Type",
          style: AppStyles.subtitle1.copyWith(color: AppColors.textLight),
        ),
        VerticalSpacing(of: 20),
        RoleSelectionCard(
          title: "Passenger",
          description: "For users who want to travel using public transport",
          icon: Icons.person,
          isSelected: _selectedRole == 'passenger',
          onTap: () {
            setState(() {
              _selectedRole = 'passenger';
              isDayMood = true;
              isFullSun = true;
            });
          },
        ),
        RoleSelectionCard(
          title: "Driver",
          description: "For bus drivers and transport operators",
          icon: Icons.directions_bus,
          isSelected: _selectedRole == 'driver',
          onTap: () {
            setState(() {
              _selectedRole = 'driver';
              isDayMood = false;
              isFullSun = false;
            });
          },
        ),
        VerticalSpacing(of: 30),
        ElevatedButton(
          style: AppStyles.primaryButton,
          onPressed: () {
            setState(() {
              _currentStep = 1;
            });
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: 50,
            child: Text("CONTINUE"),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic Information",
          style: AppStyles.subtitle1.copyWith(color: AppColors.textLight),
        ),
        VerticalSpacing(of: 20),
        _buildTextField(
          controller: _nameController,
          hintText: "Full Name",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        VerticalSpacing(),
        _buildTextField(
          controller: _emailController,
          hintText: "Email",
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        VerticalSpacing(),
        _buildTextField(
          controller: _phoneController,
          hintText: "Phone Number",
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        VerticalSpacing(),
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
        VerticalSpacing(),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: "Confirm Password",
          isPassword: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        VerticalSpacing(of: 30),
        ElevatedButton(
          style: AppStyles.primaryButton,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _currentStep = 2;
              });
            }
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: 50,
            child: Text("CONTINUE"),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSpecificForm(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedRole == 'passenger'
              ? "Address Information"
              : "Driver Details",
          style: AppStyles.subtitle1.copyWith(color: AppColors.textLight),
        ),
        VerticalSpacing(of: 20),
        if (_selectedRole == 'passenger') ...[
          _buildTextField(
            controller: _addressController,
            hintText: "Home Address",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your home address';
              }
              return null;
            },
          ),
          VerticalSpacing(),
          _buildTextField(
            controller: _workAddressController,
            hintText: "Work Address (Optional)",
            validator: null,
          ),
        ] else if (_selectedRole == 'driver') ...[
          _buildTextField(
            controller: _addressController,
            hintText: "Address",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          VerticalSpacing(),
          _buildTextField(
            controller: _licenseNumberController,
            hintText: "License Number",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your license number';
              }
              return null;
            },
          ),
          VerticalSpacing(),
          _buildTextField(
            controller: _busNumberController,
            hintText: "Bus Number",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bus number';
              }
              return null;
            },
          ),
          VerticalSpacing(),
          _buildTextField(
            controller: _busModelController,
            hintText: "Bus Model",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the bus model';
              }
              return null;
            },
          ),
          VerticalSpacing(),
          _buildTextField(
            controller: _busColorController,
            hintText: "Bus Color",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the bus color';
              }
              return null;
            },
          ),
        ],
        VerticalSpacing(of: 30),
        ElevatedButton(
          style: AppStyles.primaryButton,
          onPressed: authProvider.isLoading ? null : _register,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: 50,
            child: authProvider.isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("REGISTER"),
          ),
        ),
      ],
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
            obscureText: isPassword
                ? (controller == _passwordController
                    ? _obscurePassword
                    : _obscureConfirmPassword)
                : false,
            validator: validator,
            decoration: InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        controller == _passwordController
                            ? (_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility)
                            : (_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                        color: AppColors.textLight.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          if (controller == _passwordController) {
                            _obscurePassword = !_obscurePassword;
                          } else {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }
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
