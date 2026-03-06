import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/features/settings/data/models/profile_row.dart';
import 'package:my_first_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';

import '../../shared/widgets/navbar/app_navbar.dart';
import '../auth/widgets/auth_primary_button.dart';
import 'widgets/edit_profile_avatar_section.dart';
import 'widgets/edit_profile_form_field.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _didSeedInitialValues = false;
  bool _isSaving = false;

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedAvatarFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final profileAsync = ref.watch(profileProvider);
    final authSessionAsync = ref.watch(authSessionProvider);
    final isLoading = profileAsync.isLoading || authSessionAsync.isLoading;
    final hasError = profileAsync.hasError || authSessionAsync.hasError;

    final profile = profileAsync.valueOrNull;
    final persistedAvatarUrl = profile?.avatarUrl;
    final ImageProvider<Object>? avatarImageProvider =
        _selectedAvatarFile != null
        ? FileImage(_selectedAvatarFile!)
        : (persistedAvatarUrl != null && persistedAvatarUrl.isNotEmpty
              ? NetworkImage(persistedAvatarUrl)
              : null);

    final authUser = authSessionAsync.valueOrNull;
    if (!_didSeedInitialValues && !isLoading && !hasError && profile != null) {
      _nameController.text = profile.displayName?.trim() ?? '';
      _emailController.text = authUser?.email.trim() ?? '';
      _didSeedInitialValues = true;
    }

    return Scaffold(
      backgroundColor: AppColors.cFFF7F2EE,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cFFDEAF5F,
                      ),
                    )
                  : hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Failed to load profile.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cFF8B6758,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                ref.invalidate(profileProvider);
                                ref.invalidate(authSessionProvider);
                                _didSeedInitialValues = false;
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditProfileAvatarSection(
                            onTapChangePhoto: _isSaving ? null : _onChangePhoto,
                            imageProvider: avatarImageProvider,
                          ),
                          const SizedBox(height: 18),
                          EditProfileFormField(
                            label: 'Name',
                            controller: _nameController,
                            trailingIcon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 16),
                          EditProfileFormField(
                            label: 'Email',
                            controller: _emailController,
                            readOnly: true,
                            keyboardType: TextInputType.emailAddress,
                            trailingIcon: Icons.email_rounded,
                            helperText:
                                'Contact support to change email address.',
                          ),
                          const SizedBox(height: 36),
                          AuthPrimaryButton(
                            label: _isSaving ? 'Saving...' : 'Save Changes',
                            onPressed: _isSaving ? null : _onSaveChanges,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.of(context).maybePop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cFFA48C7E,
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
      decoration: const BoxDecoration(
        color: AppColors.cFFF7F2EE,
        border: Border(bottom: BorderSide(color: AppColors.cFFE7DDD4)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.cFF8B6758,
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.cFF8B6758,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Future<void> _onChangePhoto() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (pickedFile == null || !mounted) return;

    setState(() {
      _selectedAvatarFile = File(pickedFile.path);
    });
  }

  Future<void> _onSaveChanges() async {
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSaving = true;
    });

    try {
      final profile = await ref.read(profileProvider.future);
      var nextAvatarUrl = profile.avatarUrl;

      if (_selectedAvatarFile != null) {
        nextAvatarUrl = await ref
            .read(profileDaoProvider)
            .uploadAvatar(userId: profile.userId, file: _selectedAvatarFile!);
      }

      final updatedRow = ProfileRow(
        userId: profile.userId,
        displayName: _nameController.text.trim(),
        bio: profile.bio,
        avatarUrl: nextAvatarUrl,
      );

      await ref.read(profileDaoProvider).upsert(updatedRow);
      ref.invalidate(profileProvider);

      if (!mounted) return;
      setState(() {
        _selectedAvatarFile = null;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile changes saved.')),
      );
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to save profile.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
