import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputForm extends StatefulWidget {
  final Function(String) onPhoneSubmit;
  final bool isLoading;

  const PhoneInputForm({
    super.key,
    required this.onPhoneSubmit,
    this.isLoading = false,
  });

  @override
  State<PhoneInputForm> createState() => _PhoneInputFormState();
}

class _PhoneInputFormState extends State<PhoneInputForm> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Đảm bảo controller rỗng ban đầu
    _phoneController.clear();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (phone.startsWith('0')) {
      phone = '84${phone.substring(1)}';
    }
    if (!phone.startsWith('84')) {
      phone = '84$phone';
    }
    
    return '+$phone';
  }

  void _submitPhone() {
    if (_formKey.currentState!.validate()) {
      final formattedPhone = _formatPhoneNumber(_phoneController.text);
      widget.onPhoneSubmit(formattedPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone Input Field
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              hintText: 'Nhập số điện thoại',
              prefixText: '+84 ',
              prefixStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (value.length < 9 || value.length > 10) {
                return 'Số điện thoại không hợp lệ';
              }
              if (!value.startsWith('0')) {
                return 'Số điện thoại phải bắt đầu bằng 0';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Submit Button
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submitPhone,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Gửi mã xác thực',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}