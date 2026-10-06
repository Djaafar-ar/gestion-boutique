import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';

/// Round badge with the person's initials. The owner gets the main colour.
class UserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          user.isOwner ? scheme.primaryContainer : scheme.tertiaryContainer,
      foregroundColor:
          user.isOwner ? scheme.onPrimaryContainer : scheme.onTertiaryContainer,
      child: Text(user.initials,
          style:
              TextStyle(fontSize: radius * 0.75, fontWeight: FontWeight.bold)),
    );
  }
}
