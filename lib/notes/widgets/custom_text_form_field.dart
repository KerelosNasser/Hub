import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final int maxLines;
  final int? maxLength;
  final bool isRequired;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    required this.icon,
    this.iconColor = Colors.grey,
    this.maxLines = 1,
    this.maxLength,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.focusNode,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isFocused;
  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _isFocused = false;
    _hasText = widget.controller.text.isNotEmpty;
    
    widget.controller.addListener(_updateTextStatus);
    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_updateFocusStatus);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextStatus);
    if (widget.focusNode != null) {
      widget.focusNode!.removeListener(_updateFocusStatus);
    }
    super.dispose();
  }

  void _updateTextStatus() {
    if (mounted) {
      final hasText = widget.controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    }
  }

  void _updateFocusStatus() {
    if (mounted && widget.focusNode != null) {
      setState(() {
        _isFocused = widget.focusNode!.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? widget.iconColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: TextStyle(
            color: _isFocused ? widget.iconColor : Colors.grey.shade700,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused || _hasText ? widget.iconColor : Colors.grey.shade500,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18),
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.iconColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          counterText: widget.maxLength != null ? '' : null,
        ),
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade900,
        ),
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        textCapitalization: TextCapitalization.sentences,
        onChanged: widget.onChanged,
        validator: widget.isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
