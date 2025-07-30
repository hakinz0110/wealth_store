import 'package:flutter/material.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? bottom;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
    this.bottomNavigationBar,
    this.bottom,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBackButton,
        actions: actions,
        bottom: bottom,
      ),
      body: SafeArea(
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}

class ScrollableBaseScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? bottom;
  final EdgeInsetsGeometry padding;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ScrollableBaseScreen({
    super.key,
    required this.title,
    required this.children,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
    this.bottomNavigationBar,
    this.bottom,
    this.padding = const EdgeInsets.all(AppSpacing.medium),
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: title,
      actions: actions,
      floatingActionButton: floatingActionButton,
      showBackButton: showBackButton,
      bottomNavigationBar: bottomNavigationBar,
      bottom: bottom,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          ),
        ),
      ),
    );
  }
}

class BaseScreenLoading extends StatelessWidget {
  const BaseScreenLoading({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class BaseScreenError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const BaseScreenError({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 