import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/locale_provider.dart';

class SettingsPage extends StatelessWidget {
  final LocaleProvider localeProvider;
  const SettingsPage({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2333),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F8CFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.language_rounded, color: Color(0xFF4F8CFF), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    t.translate('language'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _LanguageOption(
                label: t.translate('english'),
                subtitle: 'English',
                selected: localeProvider.locale.languageCode == 'en',
                onTap: () => localeProvider.setLocale(const Locale('en')),
              ),
              const SizedBox(height: 8),
              _LanguageOption(
                label: t.translate('amharic'),
                subtitle: 'አማርኛ',
                selected: localeProvider.locale.languageCode == 'am',
                onTap: () => localeProvider.setLocale(const Locale('am')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected ? const Color(0xFF4F8CFF).withValues(alpha: 0.1) : Colors.transparent,
        border: Border.all(
          color: selected ? const Color(0xFF4F8CFF).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? const Color(0xFF4F8CFF) : Colors.white38,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFF4F8CFF) : Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
        ),
        onTap: onTap,
      ),
    );
  }
}
