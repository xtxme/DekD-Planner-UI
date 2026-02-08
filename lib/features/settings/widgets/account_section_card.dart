import 'package:flutter/material.dart';

class SettingsAccountCard extends StatelessWidget {
  const SettingsAccountCard({
    super.key,
    required this.name,
    required this.email,
    this.onTapProfile,
    this.onEditProfile,
    this.onSignOut,
  });

  final String name;
  final String email;
  final VoidCallback? onTapProfile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DBD2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTapProfile,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7CDC5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_4_rounded,
                        size: 42,
                        color: Color(0xFF8B6758),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF8B6758),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFA48C7E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEE4DB)),//เส้นคั่นแนวนอน
            InkWell( //ทำให้พื้นที่ตรงนั้น “กดได้”
              onTap: onEditProfile,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFFA48C7E), size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8B6758),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFC7B8AD),
                      size: 28,
                    )
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEE4DB)),
            InkWell(
              onTap: onSignOut,
              child: Padding(
                padding: EdgeInsetsGeometry.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFF04444), size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF04444),
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
    );
  }
}
