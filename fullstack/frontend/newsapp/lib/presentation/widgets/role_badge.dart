// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  final String role;
  final bool small;
  final bool outlined;

  const RoleBadge({
    super.key,
    required this.role,
    this.small = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final roleConfig = _getRoleConfig(role);

    if (outlined) {
      return Container(
        padding: small
            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: roleConfig.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(small ? 8 : 12),
          border: Border.all(color: roleConfig.color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              roleConfig.icon,
              size: small ? 12 : 14,
              color: roleConfig.color,
            ),
            if (!small) const SizedBox(width: 4),
            Text(
              roleConfig.label,
              style: TextStyle(
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: roleConfig.color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: roleConfig.color,
        borderRadius: BorderRadius.circular(small ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            roleConfig.icon,
            size: small ? 12 : 14,
            color: Colors.white,
          ),
          if (!small) const SizedBox(width: 4),
          Text(
            roleConfig.label,
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  RoleConfig _getRoleConfig(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return RoleConfig(
          label: 'Admin',
          color: Colors.red,
          icon: Icons.security,
        );
      case 'penulis':
        return RoleConfig(
          label: 'Penulis',
          color: Colors.blue,
          icon: Icons.edit,
        );
      case 'pembaca':
        return RoleConfig(
          label: 'Pembaca',
          color: Colors.green,
          icon: Icons.person,
        );
      default:
        return RoleConfig(
          label: 'User',
          color: Colors.grey,
          icon: Icons.person_outline,
        );
    }
  }
}

class RoleConfig {
  final String label;
  final Color color;
  final IconData icon;

  RoleConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

// Role Chip untuk penggunaan dalam list
class RoleChip extends StatelessWidget {
  final String role;
  final bool selected;
  final VoidCallback? onTap;

  const RoleChip({
    super.key,
    required this.role,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final roleConfig = _getRoleConfig(role);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? roleConfig.color : roleConfig.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: roleConfig.color,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              roleConfig.icon,
              size: 14,
              color: selected ? Colors.white : roleConfig.color,
            ),
            const SizedBox(width: 4),
            Text(
              roleConfig.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : roleConfig.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  RoleConfig _getRoleConfig(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return RoleConfig(
          label: 'Admin',
          color: Colors.red,
          icon: Icons.security,
        );
      case 'penulis':
        return RoleConfig(
          label: 'Penulis',
          color: Colors.blue,
          icon: Icons.edit,
        );
      case 'pembaca':
        return RoleConfig(
          label: 'Pembaca',
          color: Colors.green,
          icon: Icons.person,
        );
      default:
        return RoleConfig(
          label: 'User',
          color: Colors.grey,
          icon: Icons.person_outline,
        );
    }
  }
}

// Role selector untuk form
class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;
  final bool enabled;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const roles = ['pembaca', 'penulis', 'admin'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: roles.map((role) {
            return RoleChip(
              role: role,
              selected: selectedRole == role,
              onTap: enabled ? () => onRoleChanged(role) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}