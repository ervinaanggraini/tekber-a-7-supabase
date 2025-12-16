import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/features/theme_mode/presentation/bloc/theme_mode_cubit.dart';

class ThemeModeSettingsTile extends StatelessWidget {
  const ThemeModeSettingsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<ThemeModeCubit, ThemeModeState>(
      builder: (context, state) {
        final currentMode = state.selectedThemeMode;
        String modeText = 'System';
        if (currentMode == ThemeMode.light) {
          modeText = 'Light';
        } else if (currentMode == ThemeMode.dark) {
          modeText = 'Dark';
        }

        return ListTile(
          leading: Icon(
            currentMode == ThemeMode.dark 
                ? Icons.dark_mode 
                : currentMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
            color: AppColors.b93160,
          ),
          title: Text(
            'Theme Mode',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            modeText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: PopupMenuButton<ThemeMode>(
            icon: Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
            onSelected: (ThemeMode mode) {
              context.read<ThemeModeCubit>().changeTheme(mode);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode),
                    const SizedBox(width: 12),
                    Text('Light', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode),
                    const SizedBox(width: 12),
                    Text('Dark', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_auto),
                    const SizedBox(width: 12),
                    Text('System', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
