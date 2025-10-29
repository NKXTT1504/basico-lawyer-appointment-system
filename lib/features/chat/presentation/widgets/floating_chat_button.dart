import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    context.push('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: FloatingActionButton(
                onPressed: _onTap,
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                elevation: 8,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[600]!,
                        Colors.blue[700]!,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.chat,
                    size: 28,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FloatingChatButtonWithBadge extends StatefulWidget {
  final int? unreadCount;

  const FloatingChatButtonWithBadge({
    super.key,
    this.unreadCount,
  });

  @override
  State<FloatingChatButtonWithBadge> createState() =>
      _FloatingChatButtonWithBadgeState();
}

class _FloatingChatButtonWithBadgeState
    extends State<FloatingChatButtonWithBadge> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.unreadCount != null && widget.unreadCount! > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FloatingChatButtonWithBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unreadCount != null && widget.unreadCount! > 0) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    context.push('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: FloatingActionButton(
                  onPressed: _onTap,
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  elevation: 8,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue[600]!,
                          Colors.blue[700]!,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.chat,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.unreadCount != null && widget.unreadCount! > 0)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  widget.unreadCount! > 99
                      ? '99+'
                      : widget.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
