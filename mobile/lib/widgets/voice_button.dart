import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/voice_service.dart';

class VoiceButton extends StatefulWidget {
  const VoiceButton({super.key});
  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  bool _listening = false;
  String _heard = '';

  Future<void> _toggle() async {
    final voice = VoiceService();
    if (_listening) {
      await voice.stop();
      setState(() => _listening = false);
      return;
    }
    final ok = await voice.init();
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition unavailable')),
        );
      }
      return;
    }
    setState(() => _listening = true);
    await voice.speak('Yes, kya kaam hai?');
    await voice.listen(onResult: (text) {
      setState(() => _heard = text);
    });
    Future.delayed(const Duration(seconds: 9), () async {
      if (!mounted) return;
      await voice.stop();
      setState(() => _listening = false);
      if (_heard.isNotEmpty) _handle(_heard);
    });
  }

  void _handle(String text) {
    final cmd = VoiceService().parseCommand(text);
    String reply;
    if (cmd == null) {
      reply = 'Maaf kijiye, samjha nahi.';
    } else {
      switch (cmd['intent']) {
        case 'schedule_meeting': reply = 'Meeting schedule screen open kar raha hoon.'; break;
        case 'add_lead': reply = 'Naya lead add kar raha hoon.'; break;
        case 'today_meetings': reply = 'Aaj ki meetings dikha raha hoon.'; break;
        case 'today_followups': reply = 'Aaj ke follow-ups dikha raha hoon.'; break;
        default: reply = 'Done.';
      }
    }
    VoiceService().speak(reply);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You said: $text'), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _listening ? [AppColors.red, Colors.deepOrange] : [AppColors.primary, AppColors.teal700],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_listening ? AppColors.red : AppColors.primary).withOpacity(0.4),
              blurRadius: 16, spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(_listening ? Icons.stop : Icons.mic, color: Colors.white, size: 26),
      ),
    );
  }
}
