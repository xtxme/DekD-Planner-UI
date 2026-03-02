import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

import '../auth/widgets/auth_primary_button.dart';
import '../../shared/widgets/navbar/app_navbar.dart';
import 'package:my_first_app/shared/providers/nav_provider.dart';
import 'widgets/edit_profile_avatar_section.dart';
import 'widgets/edit_profile_form_field.dart';

import 'package:my_first_app/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:my_first_app/features/settings/data/models/profile_row.dart';
import 'package:my_first_app/features/settings/presentation/providers/settings_providers.dart';


class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key, this.withNavBar = true});

  final bool withNavBar;

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  //เพิ่ม state กัน controller โดน set ซ้ำ
  bool _didSeedInitialValues = false; //ใช้เติมค่าจาก database เข้า controller แค่ครั้งเดียว
  bool _isSaving = false; //ใช้ disable ปุ่มตอนกำลังบันทึก

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  //profileProvider = ดึงข้อมูลโปรไฟล์จริง
  //_didSeedInitialValues ... = เอาข้อมูลจริงมาแสดงในฟอร์ม
  //profileDaoProvider.upsert(...) = เซฟกลับ database

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentNavIndexProvider);
    final profileAsync = ref.watch(profileProvider); //อ่านข้อมูลโปรไฟล์จาก provider
    final authSessionAsync = ref.watch(authSessionProvider);

    final profile = profileAsync.valueOrNull;
    final authUser = authSessionAsync.valueOrNull;
    //data มาแล้วหรือยัง แล้วค่อย seed ค่า
    if (!_didSeedInitialValues && profile != null ) {
      _nameController.text = profile.displayName?.trim() ?? '';
      _bioController.text = profile.bio?.trim() ?? '';
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditProfileAvatarSection(onTapChangePhoto: _onChangePhoto),
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
                      helperText: 'Contact support to change email address.',
                    ),
                    const SizedBox(height: 16),
                    EditProfileFormField(
                      label: 'Bio',
                      controller: _bioController,
                      maxLines: 3,
                      minLines: 3,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 36),
                    AuthPrimaryButton(
                      label: 'Save Changes',
                      onPressed: _isSaving ? null : _onSaveChanges,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
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

  void _onChangePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change photo action not connected yet.')),
    );
  }

  Future<void> _onSaveChanges() async{
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile is not ready yet.')),
    );
    return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile changes saved.')));
  }
}
