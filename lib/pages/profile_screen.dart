import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../routes/routes.dart';
import '../style/color_style.dart';
import '../style/text_style.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final storedUserName = GetStorage().read<String>('userName');
    final Stream<AppUser?> userStream = storedUserName != null
        ? userRepository.watchUserByName(storedUserName)
        : userRepository.watchCurrentUser();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: StreamBuilder<AppUser?>(
              stream: userStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final user = snapshot.data;
                if (user == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                  });
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(user: user),
                      const SizedBox(height: 16),
                      _StatsGrid(user: user),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: ColorsBets.whiteHD,
          backgroundImage: user.photo.isNotEmpty ? NetworkImage(user.photo) : null,
          child: user.photo.isEmpty
              ? const Icon(
                  Icons.person,
                  color: ColorsBets.blackHD,
                  size: 32,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: MemoText.createInputMainText,
              ),
              Text(
                'Punti totali: ${user.points}',
                style: MemoText.thirdRowMatchInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsBets.whiteHD.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Streak', value: '${user.streak}')),
              const SizedBox(width: 8),
              Expanded(child: _StatTile(label: 'Accuracy', value: '${(user.accuracy * 100).toStringAsFixed(1)}%')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Corretti', value: '${user.correctPredictions}')),
              const SizedBox(width: 8),
              Expanded(child: _StatTile(label: 'Sbagliati', value: '${user.wrongPredictions}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsBets.whiteHD.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: MemoText.thirdRowMatchInfo,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: MemoText.createInputMainText,
          ),
        ],
      ),
    );
  }
}
