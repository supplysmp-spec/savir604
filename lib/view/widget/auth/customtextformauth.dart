import 'package:flutter/material.dart';

class Customtextformauth extends StatefulWidget {
  const Customtextformauth({
    super.key,
    this.obscureText,
    this.onTapIcon,
    required this.hinttext,
    required this.labeltext,
    required this.iconData,
    required this.mycontroller,
    required this.valid,
    required this.isNumber,
  });

  final String hinttext;
  final String labeltext;
  final IconData iconData;
  final TextEditingController? mycontroller;
  final String? Function(String?) valid;
  final bool isNumber;
  final bool? obscureText;
  final void Function()? onTapIcon;

  @override
  State<Customtextformauth> createState() => _CustomtextformauthState();
}

class _CustomtextformauthState extends State<Customtextformauth> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (bool hasFocus) => setState(() => _isFocused = hasFocus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        transform: Matrix4.identity()..scale(_isFocused ? 1.01 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _isFocused ? const Color(0xFFFFFEFB) : const Color(0xFFFFFCF7),
              _isFocused ? const Color(0xFFF9F0DD) : const Color(0xFFFBF6ED),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isFocused ? const Color(0xFFD6B878) : const Color(0xFFD9C7AA),
            width: _isFocused ? 1.8 : 1.2,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _isFocused
                  ? const Color(0xFFD6B878).withValues(alpha: 0.22)
                  : const Color(0xFFB9A482).withValues(alpha: 0.10),
              blurRadius: _isFocused ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: 12,
              bottom: 12,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: _isFocused
                        ? const <Color>[Color(0xFFE5C981), Color(0xFFBD9147)]
                        : const <Color>[Color(0xFFE8D6B3), Color(0xFFD9C19A)],
                  ),
                ),
              ),
            ),
            TextFormField(
              keyboardType: widget.isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              validator: widget.valid,
              controller: widget.mycontroller,
              obscureText: widget.obscureText ?? false,
              cursorColor: const Color(0xFF6E5221),
              autocorrect: false,
              enableSuggestions: widget.obscureText != true,
              style: const TextStyle(
                color: Color(0xFF16120E),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
                prefixIconConstraints: const BoxConstraints(minWidth: 54),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: _isFocused
                            ? const <Color>[Color(0xFFF1DCA8), Color(0xFFD6B878)]
                            : const <Color>[Color(0xFFF4E6C4), Color(0xFFE3CFA2)],
                      ),
                    ),
                    child: Icon(
                      widget.iconData,
                      color: const Color(0xFF4F3D22),
                      size: 18,
                    ),
                  ),
                ),
                labelText: widget.labeltext,
                labelStyle: TextStyle(
                  color: _isFocused ? const Color(0xFFB9924E) : const Color(0xFF6F6253),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                hintText: widget.hinttext,
                hintStyle: const TextStyle(
                  color: Color(0xFF9A8B78),
                  fontSize: 14,
                ),
                floatingLabelStyle: const TextStyle(
                  color: Color(0xFF8C6A2F),
                  fontWeight: FontWeight.w700,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                suffixIcon: widget.onTapIcon == null
                    ? null
                    : InkWell(
                        onTap: widget.onTapIcon,
                        child: Icon(
                          widget.iconData,
                          color: _isFocused
                              ? const Color(0xFFB9924E)
                              : const Color(0xFF7D6D5B),
                          size: 19,
                        ),
                      ),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
