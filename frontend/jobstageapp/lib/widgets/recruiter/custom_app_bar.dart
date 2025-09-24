import 'package:flutter/material.dart';
import '../../theme/recruiter_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showSearch;
  final String? searchHint;
  final Function(String)? onSearchChanged;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showSearch = false,
    this.searchHint,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: RecruiterTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: leading,
      title: Text(
        title,
        style: RecruiterTheme.titleLarge.copyWith(color: Colors.white),
      ),
      actions: actions,
      bottom: showSearch
          ? PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: searchHint ?? 'Rechercher...',
                    hintStyle: RecruiterTheme.bodyMedium.copyWith(
                      color: RecruiterTheme.customColors['secondary_text'],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: RecruiterTheme.customColors['secondary_text'],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(showSearch ? 120.0 : kToolbarHeight);
}
