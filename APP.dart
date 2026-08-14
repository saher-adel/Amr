Widget _buildPulsingSecretButton(JourneyPageData page) {
  return AnimatedBuilder(
    animation: _pulseController,
    builder: (context, child) {
      final pulse = 0.85 + (_pulseController.value * 0.15);
      final glow = 8 + (_pulseController.value * 14);
      return Transform.scale(
        scale: pulse,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showSecretNoteModal(page),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    page.themeAccent,
                    Color.lerp(page.themeAccent, Colors.white, 0.25)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: page.themeAccent.withValues(alpha: 0.65),
                    blurRadius: glow,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_open_rounded,
                      size: 16, color: Colors.black),
                  const SizedBox(width: 6),
                  const Text(
                    'اكتشف سر المحطة',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
