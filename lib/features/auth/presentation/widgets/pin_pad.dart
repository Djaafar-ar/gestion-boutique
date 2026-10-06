import 'package:flutter/material.dart';

/// Four dots and a big number keypad. Calls [onCompleted] once 4 digits
/// are typed, then clears itself.
class PinPad extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final bool enabled;

  const PinPad({super.key, required this.onCompleted, this.enabled = true});

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  static const _length = 4;
  String _pin = '';

  void _press(String digit) {
    if (!widget.enabled || _pin.length >= _length) return;
    setState(() => _pin += digit);
    if (_pin.length == _length) {
      final pin = _pin;
      // Let the 4th dot appear before checking.
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        setState(() => _pin = '');
        widget.onCompleted(pin);
      });
    }
  }

  void _erase() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Digits keep the same layout in Arabic, like on a phone keypad.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.all(8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        i < _pin.length ? scheme.primary : Colors.transparent,
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '<'],
          ])
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final key in row)
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: SizedBox(
                      width: 72,
                      height: 60,
                      child: key.isEmpty
                          ? null
                          : key == '<'
                              ? IconButton(
                                  onPressed: widget.enabled ? _erase : null,
                                  icon: const Icon(Icons.backspace_outlined),
                                )
                              : FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  onPressed:
                                      widget.enabled ? () => _press(key) : null,
                                  child: Text(key,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600)),
                                ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
