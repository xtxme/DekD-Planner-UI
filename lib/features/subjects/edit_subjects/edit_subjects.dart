import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/features/subjects/data/models/subject_row.dart';
import 'package:my_first_app/features/subjects/presentation/providers/subject_providers.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import 'material_all_icons_pack.dart' as material_all_icons_pack;
import 'widgets/edit_subjects_appearance_card.dart';
import 'widgets/edit_subjects_field_shell.dart';
import 'widgets/edit_subjects_section_label.dart';

class EditSubjectsPage extends ConsumerStatefulWidget {
  const EditSubjectsPage({
    super.key,
    this.withNavBar = true,
    required this.subject,
  });

  final bool withNavBar;
  final SubjectRow subject;

  @override
  ConsumerState<EditSubjectsPage> createState() => _EditSubjectsPageState();
}

class _EditSubjectsPageState extends ConsumerState<EditSubjectsPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _codeFocusNode;
  late final FocusNode _descriptionFocusNode;

  final List<Color> _colorChoices = [
    AppColors.headerSurface,
    AppColors.accent,
    AppColors.cFFB08F7E,
    AppColors.textPrimary,
  ];

  static const List<IconData> _defaultIconChoices = [
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.menu_book_rounded,
    Icons.palette_rounded,
    Icons.public_rounded,
  ];

  final List<IconData> _iconChoices = [..._defaultIconChoices];

  Color _selectedColor = AppColors.accent;
  IconData _selectedIcon = Icons.calculate_rounded;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _codeController = TextEditingController(text: widget.subject.code);
    _descriptionController = TextEditingController(
      text: widget.subject.description,
    );
    _selectedColor = Color(widget.subject.colorValue);
    _selectedIcon = widget.subject.iconCodepoint == 0
        ? Icons.menu_book_rounded
        : IconData(widget.subject.iconCodepoint, fontFamily: 'MaterialIcons');
    if (!_colorChoices.contains(_selectedColor)) {
      _colorChoices.add(_selectedColor);
    }
    if (!_iconChoices.contains(_selectedIcon)) {
      _iconChoices.add(_selectedIcon);
    }
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
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: true,
                      autocorrect: true,
                      minLines: 1,
                      maxLines: null,
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
                    const EditSubjectsSectionLabel(text: 'SUBJECT CODE'),
                    const SizedBox(height: 10),
                    EditSubjectsFieldShell(
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
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                              enableSuggestions: false,
                              autocorrect: false,
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
                    const EditSubjectsSectionLabel(text: 'DESCRIPTION'),
                    const SizedBox(height: 10),
                    EditSubjectsFieldShell(
                      isFocused: _descriptionFocusNode.hasFocus,
                      minHeight: 170,
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: true,
                        autocorrect: true,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const EditSubjectsSectionLabel(text: 'APPEARANCE'),
                    const SizedBox(height: 10),
                    EditSubjectsAppearanceCard(
                      colorChoices: _colorChoices,
                      selectedColor: _selectedColor,
                      iconChoices: _iconChoices,
                      selectedIcon: _selectedIcon,
                      onColorTap: (value) {
                        setState(() => _selectedColor = value);
                      },
                      onAddColorTap: _onAddColorPressed,
                      onIconTap: (value) {
                        setState(() => _selectedIcon = value);
                      },
                      onAddIconTap: _onAddIconPressed,
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
      height: 72,
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

  Future<void> _onUpdatePressed() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Subject name is required.')),
        );
      return;
    }

    final updated = widget.subject.copyWith(
      name: name,
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      colorValue: _selectedColor.toARGB32(),
      iconCodepoint: _selectedIcon.codePoint,
    );

    try {
      await ref.read(subjectDaoProvider).update(updated);
      ref.invalidate(subjectListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Subject updated successfully.')),
          );
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Failed to update subject: $e')),
          );
      }
    }
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onAddColorPressed() async {
    var tempColor = _selectedColor;
    final hexController = TextEditingController(
      text: tempColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2),
    );

    final pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              hexInputBar: true,
              hexInputController: hexController,
              portraitOnly: true,
              labelTypes: const [
                ColorLabelType.rgb,
                ColorLabelType.hsv,
                ColorLabelType.hsl,
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(tempColor),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    hexController.dispose();

    if (!mounted || pickedColor == null) {
      return;
    }

    setState(() {
      if (!_colorChoices.contains(pickedColor)) {
        _colorChoices.add(pickedColor);
      }
      _selectedColor = pickedColor;
    });
  }

  Future<void> _onAddIconPressed() async {
    final pickedIcon = await showIconPicker(
      context,
      configuration: SinglePickerConfiguration(
        adaptiveDialog: false,
        showSearchBar: true,
        searchHintText: 'Search icon',
        iconSize: 30,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        title: const Text(
          'Add Icon',
          style: TextStyle(
            fontSize: 48 / 2,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        closeChild: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 34 / 2,
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
        iconColor: AppColors.secondaryText,
        backgroundColor: AppColors.surface,
        iconPickerShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        iconPackModes: const [IconPack.custom],
        customIconPack: material_all_icons_pack.allIcons,
        constraints: const BoxConstraints(
          maxHeight: 700,
          minHeight: 480,
          minWidth: 320,
          maxWidth: 380,
        ),
      ),
    );

    if (!mounted || pickedIcon == null) {
      return;
    }

    setState(() {
      if (!_iconChoices.contains(pickedIcon.data)) {
        _iconChoices.add(pickedIcon.data);
      }
      _selectedIcon = pickedIcon.data;
    });
  }
}
