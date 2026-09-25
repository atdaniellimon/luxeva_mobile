import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class CopyChip extends StatefulWidget {
  final String textToCopy;
  final String label;

  const CopyChip({
    super.key,
    required this.textToCopy,
    this.label = 'Copiar',
  });

  @override
  State<CopyChip> createState() => _CopyChipState();
}

class _CopyChipState extends State<CopyChip> {
  bool _copied = false;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    HapticFeedback.lightImpact();
    setState(() => _copied = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: _handleCopy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _copied ? LuxevaTheme.goldAccent : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _copied ? LuxevaTheme.goldLight : LuxevaTheme.borderGold,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? CupertinoIcons.checkmark_alt : CupertinoIcons.doc_on_doc,
              size: 13,
              color: _copied ? LuxevaTheme.obsidianBg : LuxevaTheme.goldAccent,
            ),
            const SizedBox(width: 4),
            Text(
              _copied ? 'Copiado' : widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: _copied ? LuxevaTheme.obsidianBg : LuxevaTheme.goldAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
