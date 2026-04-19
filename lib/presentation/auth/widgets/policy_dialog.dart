import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PolicyDialog extends StatefulWidget {
  final int initialTab;

  const PolicyDialog({
    super.key,
    required this.initialTab,
  });

  @override
  State<PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicySection {
  final String title;
  final String body;

  const _PolicySection({
    required this.title,
    required this.body,
  });
}

class _PolicyDialogState extends State<PolicyDialog> {
  List<_PolicySection> _parsePolicySections(String content) {
    final lines = content.split('\n');
    final sections = <_PolicySection>[];

    String? currentTitle;
    final currentBody = StringBuffer();

    void flush() {
      if (currentTitle == null) return;
      sections.add(
        _PolicySection(
          title: currentTitle,
          body: currentBody.toString().trim(),
        ),
      );
      currentBody.clear();
    }

    for (final line in lines) {
      if (line.startsWith('## ')) {
        flush();
        currentTitle = line.substring(3).trim();
        continue;
      }

      if (currentTitle != null) {
        currentBody.writeln(line);
      }
    }

    flush();
    return sections;
  }

  Widget _buildMarkdownBody(BuildContext context, String body) {
    final theme = Theme.of(context);
    final lines = body.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final text = line.trim();

        if (text.isEmpty) {
          return const SizedBox(height: 10);
        }

        if (text.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Text(
              text.substring(4),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final assetPath = locale.languageCode == 'vi'
        ? 'assets/policy/privacy_vi.md'
        : 'assets/policy/privacy_en.md';

    return FutureBuilder<String>(
      future: rootBundle.loadString(assetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const SizedBox(
              height: 220,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Unable to load policy document.'),
            ),
          );
        }

        final sections = _parsePolicySections(snapshot.data!);
        final effectiveSections = sections.isEmpty ? const <_PolicySection>[] : sections;
        final selectedIndex = effectiveSections.isEmpty
            ? 0
            : widget.initialTab.clamp(0, effectiveSections.length - 1);

        return DefaultTabController(
          length: effectiveSections.length,
          initialIndex: selectedIndex,
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: theme.colorScheme.surface,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 640,
                maxHeight: MediaQuery.of(context).size.height * 0.84,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    isScrollable: true,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    tabs: effectiveSections
                        .map(
                          (section) => Tab(
                            text: section.title,
                          ),
                        )
                        .toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: effectiveSections
                          .map(
                            (section) => SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              child: _buildMarkdownBody(context, section.body),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
