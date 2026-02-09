import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/navbar/app_navbar.dart';
import '../../../shared/widgets/navbar/provider.dart';
import 'widgets/add_subjects_appearance_card.dart';
import 'widgets/add_subjects_field_shell.dart';
import 'widgets/add_subjects_section_label.dart';

class AddSubjectsPage extends ConsumerStatefulWidget {
  const AddSubjectsPage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<AddSubjectsPage> createState() => _AddSubjectsPageState();
}

class _AddSubjectsPageState extends ConsumerState<AddSubjectsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _codeFocusNode;
  late final FocusNode _descriptionFocusNode;

  static const List<Color> _colorChoices = [
    AppColors.headerSurface,
    AppColors.accent,
    AppColors.cFFB08F7E,
    AppColors.textPrimary,
  ];

  static const List<IconData> _iconChoices = [
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.menu_book_rounded,
    Icons.palette_rounded,
    Icons.public_rounded,
  ];

  Color _selectedColor = AppColors.accent;
  IconData _selectedIcon = Icons.calculate_rounded;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Mathematics');
    _codeController = TextEditingController(text: 'MATH101');
    _descriptionController = TextEditingController(
      text: 'Mon/Wed 10:00 AM - Room 402',
    );
    _nameFocusNode = FocusNode();
    _codeFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _nameFocusNode.addListener(_onFocusChanged);
    _codeFocusNode.addListener(_onFocusChanged);
    _descriptionFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onFocusChanged);
    _codeFocusNode.removeListener(_onFocusChanged);
    _descriptionFocusNode.removeListener(_onFocusChanged);
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _codeFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBackgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subject Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryText,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      height: _nameFocusNode.hasFocus ? 2 : 1.5,
                      color: _nameFocusNode.hasFocus
                          ? AppColors.accent
                          : AppColors.border,
                    ),
                    const SizedBox(height: 24),
                    const AddSubjectsSectionLabel(text: 'SUBJECT CODE'),
                    const SizedBox(height: 10),
                    AddSubjectsFieldShell(
                      isFocused: _codeFocusNode.hasFocus,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              '#',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              focusNode: _codeFocusNode,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AddSubjectsSectionLabel(text: 'DESCRIPTION'),
                    const SizedBox(height: 10),
                    AddSubjectsFieldShell(
                      isFocused: _descriptionFocusNode.hasFocus,
                      minHeight: 170,
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        minLines: 4,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write subject details',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 2, bottom: 2),
                            child: Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.secondaryText.withValues(
                                alpha: 0.32,
                              ),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AddSubjectsSectionLabel(text: 'APPEARANCE'),
                    const SizedBox(height: 10),
                    AddSubjectsAppearanceCard(
                      colorChoices: _colorChoices,
                      selectedColor: _selectedColor,
                      iconChoices: _iconChoices,
                      selectedIcon: _selectedIcon,
                      onColorTap: (value) {
                        setState(() => _selectedColor = value);
                      },
                      onIconTap: (value) {
                        setState(() => _selectedIcon = value);
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: FilledButton.icon(
                        onPressed: _onUpdatePressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        icon: const Icon(Icons.save_rounded, size: 30),
                        label: const Text(
                          'Update Subject',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.withNavBar
          ? AppNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                ref.read(currentNavIndexProvider.notifier).state = index;
              },
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(color: AppColors.headerSurface),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 30,
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Subject',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  void _onUpdatePressed() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Subject updated (UI preview).')),
      );
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
