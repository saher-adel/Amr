import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MemoryJourneyApp());
  });
}

class MemoryJourneyApp extends StatelessWidget {
  const MemoryJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رحلة الذكريات المتكاملة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF180D08),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD7A15C),
          secondary: Color(0xFFA06236),
          surface: Color(0xFF2A1810),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: JourneyScreen(),
      ),
    );
  }
}

class JourneyPageData {
  final String id;
  final String imagePath;
  final String characterPath;
  final String title;
  final String subtitle;
  final String message;
  final String secretNote;
  final Alignment signAlignment;
  final Alignment giftAlignment;
  final double characterScale;
  final Color themeAccent;

  JourneyPageData({
    required this.id,
    required this.imagePath,
    required this.characterPath,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.secretNote,
    required this.signAlignment,
    required this.giftAlignment,
    this.characterScale = 1.4,
    this.themeAccent = const Color(0xFFE5B869),
  });
}

class TouchBubble {
  Offset position;
  double radius;
  Color color;
  double opacity;
  double speedY;

  TouchBubble({
    required this.position,
    required this.radius,
    required this.color,
    this.opacity = 0.9,
    required this.speedY,
  });
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isPlayingMusic = false;
  bool _isCinematicMode = false;
  bool _showCard = false;
  final Set<int> _completedSteps = {0};
  final Map<int, String> _userNotes = {};

  final AudioPlayer _audioPlayer = AudioPlayer();
  late PageController _pageController;

  late AnimationController _particleController;
  late AnimationController _confettiController;
  late AnimationController _touchAnimationController;
  late AnimationController _entranceController;
  late Animation<double> _uiFadeAnimation;

  double _pageOffset = 0.0;

  final List<TouchBubble> _bubbles = [];

  static const Color _brownDark = Color(0xFF1E110A);
  static const Color _brownMedium = Color(0xFF3A2114);
  static const Color _brownLight = Color(0xFF5C3822);
  static const Color _goldWarm = Color(0xFFE5B869);

  final List<Achievement> _achievements = [
    Achievement(
        title: 'المستكشف الشغوف',
        description: 'وصلت إلى المحطة الأولى وبدأت رحلتك العاطرة.',
        icon: Icons.explore_rounded,
        isUnlocked: false),
    Achievement(
        title: 'عاشق الأفق والغروب',
        description: 'وصلت إلى المحطة الثانية وتأملت سحر الساحل.',
        icon: Icons.wb_twilight_rounded,
        isUnlocked: false),
    Achievement(
        title: 'حارس الأضواء',
        description: 'وصلت إلى المحطة الثالثة واحتفلت تحت شجرة الأمنيات.',
        icon: Icons.auto_awesome_rounded,
        isUnlocked: false),
    Achievement(
        title: 'دليل النور',
        description: 'وصلت إلى المحطة الرابعة وعبرت ممر الفوانيس المضاءة.',
        icon: Icons.lightbulb_rounded,
        isUnlocked: false),
    Achievement(
        title: 'سيد الذكريات',
        description: 'وصلت إلى مرسى الذكريات وختمت كامل الرحلة بنجاح.',
        icon: Icons.workspace_premium_rounded,
        isUnlocked: false),
  ];

  final List<JourneyPageData> _pages = [
    JourneyPageData(
      id: 'step_1',
      imagePath: 'assets/download_1.png',
      characterPath: 'assets/character_1.png',
      title: 'بداية الطريق العاطر',
      subtitle: 'المحطة الأولى',
      message:
          'أهلاً بك عزيزي في أول خطوة من رحلتك الجمالية... اضغط "ابدأ" للرحيل عبر الذكريات.',
      secretNote:
          '🎁 سر المحطة الأولى: "أجمل البدايات هي تلك التي تبدأ بابتسامة صادقة ونية دافئة يا صديقي."',
      signAlignment: const Alignment(0.55, -0.30),
      giftAlignment: const Alignment(-0.65, -0.35),
      characterScale: 1.5,
      themeAccent: const Color(0xFFE5B869),
    ),
    JourneyPageData(
      id: 'step_2',
      imagePath: 'assets/download_4.png',
      characterPath: 'assets/character_2.png',
      title: 'أفق الساحل والغروب',
      subtitle: 'المحطة الثانية',
      message:
          'كل غروب على شاطئ البحر يهمس لك بذكرى دافئة ولحظات خلدها الزمان.',
      secretNote:
          '✨ سر المحطة الثانية: "البحر يحتفظ بجميع أسرارك، والغروب يعيدها لك حنيناً."',
      signAlignment: const Alignment(0.60, -0.20),
      giftAlignment: const Alignment(-0.70, 0.0),
      characterScale: 1.45,
      themeAccent: const Color(0xFFD48C46),
    ),
    JourneyPageData(
      id: 'step_3',
      imagePath: 'assets/download_5.png',
      characterPath: 'assets/character_3.png',
      title: 'ليلة الأضواء والبهجة',
      subtitle: 'المحطة الثالثة',
      message:
          'تحت بريق الشجرة الذهبية والأمنيات العالية، تشرق ابتسامتك الخالصة.',
      secretNote:
          '🌟 سر المحطة الثالثة: "الأمنيات التي تتمناها بقلب نقي تجد طريقها دائماً للإجابة."',
      signAlignment: const Alignment(0.55, -0.25),
      giftAlignment: const Alignment(-0.60, -0.30),
      characterScale: 1.6,
      themeAccent: const Color(0xFFF0C265),
    ),
    JourneyPageData(
      id: 'step_4',
      imagePath: 'assets/download_2.png',
      characterPath: 'assets/character_4.png',
      title: 'ممر الفوانيس المضاءة',
      subtitle: 'المحطة الرابعة',
      message: 'مهما طال الطريق وتوسعت مسافاته، فنور المحبة يضيء دربك دائماً.',
      secretNote:
          '🏮 سر المحطة الرابعة: "النور الذي ينبع من داخلك لا يمكن للظلام أن يطفئه."',
      signAlignment: const Alignment(0.65, -0.15),
      giftAlignment: const Alignment(-0.65, -0.20),
      characterScale: 1.5,
      themeAccent: const Color(0xFFC88242),
    ),
    JourneyPageData(
      id: 'step_5',
      imagePath: 'assets/download_3.png',
      characterPath: 'assets/character_5.png',
      title: 'مرسى الذكريات السعيدة',
      subtitle: 'المحطة الأخيرة',
      message: 'نهاية هذه الرحلة هي مجرد بداية لقصص أعمق وأحلام أبهى تنتظرك.',
      secretNote:
          '👑 سر المحطة الخامسة: "كل نهاية هي في الحقيقة بوابة لرحلة أكثر جمالاً وسحراً لك."',
      signAlignment: const Alignment(0.55, -0.20),
      giftAlignment: const Alignment(-0.60, 0.10),
      characterScale: 1.65,
      themeAccent: const Color(0xFFE2A76F),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageOffset = 0.0;
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _pageOffset = _pageController.page!;
        });
      }
    });

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _uiFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _touchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateBubbles);

    _touchAnimationController.repeat();
    _entranceController.forward();
    _scheduleCardReveal();
  }

  // يؤخر ظهور صندوق الرسالة لحد ما الصورة تظهر الأول، وبعدها يظهر بانيميشن
  void _scheduleCardReveal() {
    setState(() {
      _showCard = false;
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        setState(() {
          _showCard = true;
        });
      }
    });
  }

  void _updateBubbles() {
    if (_bubbles.isEmpty) return;
    setState(() {
      for (int i = _bubbles.length - 1; i >= 0; i--) {
        final b = _bubbles[i];
        b.position = Offset(b.position.dx, b.position.dy - b.speedY);
        b.opacity -= 0.02;
        b.radius += 0.3;
        if (b.opacity <= 0) {
          _bubbles.removeAt(i);
        }
      }
    });
  }

  void _addTouchEffect(Offset globalPosition) {
    final random = math.Random();
    final accent = _pages[_currentIndex].themeAccent;

    setState(() {
      for (int i = 0; i < 5; i++) {
        _bubbles.add(
          TouchBubble(
            position: globalPosition +
                Offset(random.nextDouble() * 20 - 10,
                    random.nextDouble() * 20 - 10),
            radius: random.nextDouble() * 8 + 6,
            color: Color.lerp(accent, _goldWarm, random.nextDouble())!,
            speedY: random.nextDouble() * 2 + 1.5,
          ),
        );
      }
    });
  }

  void _unlockAchievementForPage(int pageIndex) {
    bool isNewUnlock = !_achievements[pageIndex].isUnlocked;

    setState(() {
      _achievements[pageIndex].isUnlocked = true;
    });

    if (isNewUnlock) {
      _showTitleUnlockedDialog(_achievements[pageIndex]);
    }
  }

  void _showTitleUnlockedDialog(Achievement achievement) {
    final page = _pages[_currentIndex];
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.elasticOut);
        return Transform.scale(
          scale: curve.value,
          child: Opacity(
            opacity: anim1.value,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: _brownDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: page.themeAccent, width: 3),
                ),
                title: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: page.themeAccent.withValues(alpha: 0.2),
                          border: Border.all(color: page.themeAccent, width: 2),
                        ),
                        child: Icon(achievement.icon,
                            color: page.themeAccent, size: 54),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '🏆 لقب جديد مُكتسب!',
                        style: TextStyle(
                          color: page.themeAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE2CBB4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: page.themeAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('متابعة الرحلة',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleMusic() async {
    try {
      if (_isPlayingMusic) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('background_music.mp3'));
      }
      setState(() {
        _isPlayingMusic = !_isPlayingMusic;
      });
    } catch (e) {
      debugPrint("خطأ في تشغيل الصوت: $e");
    }
  }

  void _changePage(int newIndex) {
    if (newIndex >= 0 && newIndex < _pages.length) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
      _completedSteps.add(newIndex);
      _entranceController.reset();
      _entranceController.forward();
    });

    _scheduleCardReveal();

    if (newIndex == _pages.length - 1) {
      _confettiController.reset();
      _confettiController.forward();
      Future.delayed(const Duration(milliseconds: 2000), () {
        _showCompletionCertificate();
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    _entranceController.dispose();
    _particleController.dispose();
    _confettiController.dispose();
    _touchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          setState(() {
            _isCinematicMode = !_isCinematicMode;
          });
        },
        child: Listener(
          onPointerDown: (event) => _addTouchEffect(event.position),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final delta = (_pageOffset - index).clamp(-1.0, 1.0);
                  final scale = 1.0 + (0.10 * (1 - delta.abs()));
                  final fade = (1 - (delta.abs() * 0.55)).clamp(0.45, 1.0);
                  return Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Image.asset(
                          page.imagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: size.width,
                          height: size.height,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackBackground(page),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _brownDark.withValues(alpha: 0.60),
                      Colors.transparent,
                      _brownDark.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: BackgroundParticlesPainter(
                      _particleController.value,
                      currentPage.themeAccent,
                    ),
                  );
                },
              ),
              // شخصية ثابتة بعيدة عن صندوق الرسالة، تختفي وتظهر بانيميشن ناعم عند تغيير الصفحة
              Align(
                alignment: const Alignment(-0.6, 0.80),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 550),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.78, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animation, curve: Curves.easeOutBack),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.18),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<String>(currentPage.characterPath),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120 * currentPage.characterScale,
                        height: 145 * currentPage.characterScale,
                        child: Image.asset(
                          currentPage.characterPath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackCharacter(currentPage),
                        ),
                      ),
                      Container(
                        width: 60 * currentPage.characterScale,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // صندوق الرسالة بتصميم زجاجي عصري، يمكن الضغط عليه لعرض السر الخاص بالمحطة
              AnimatedAlign(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                alignment: currentPage.signAlignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.10),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _showCard
                        ? _buildStoryCard(
                            currentPage,
                            key: ValueKey<String>('card_${currentPage.id}'),
                          )
                        : const SizedBox.shrink(key: ValueKey('card_empty')),
                  ),
                ),
              ),
              CustomPaint(
                size: size,
                painter: TouchBubblePainter(_bubbles),
              ),
              if (_confettiController.isAnimating)
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: ConfettiPainter(_confettiController.value),
                    );
                  },
                ),
              if (!_isCinematicMode)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 20,
                  right: 20,
                  child: FadeTransition(
                    opacity: _uiFadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _brownMedium.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: currentPage.themeAccent
                                  .withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.explore_rounded,
                                  color: currentPage.themeAccent, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${_currentIndex + 1} / ${_pages.length}',
                                style: const TextStyle(
                                  color: Color(0xFFFFF8E1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildHeaderCircleButton(
                              icon: Icons.emoji_events_rounded,
                              accentColor: currentPage.themeAccent,
                              onTap: _showAchievementsModal,
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderCircleButton(
                              icon: Icons.map_rounded,
                              accentColor: currentPage.themeAccent,
                              onTap: _showMapModal,
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderCircleButton(
                              icon: Icons.zoom_in_rounded,
                              accentColor: currentPage.themeAccent,
                              onTap: () => _showFullImageGallery(currentPage),
                            ),
                            const SizedBox(width: 8),
                            _buildHeaderCircleButton(
                              icon: _isPlayingMusic
                                  ? Icons.music_note_rounded
                                  : Icons.music_off_rounded,
                              accentColor: currentPage.themeAccent,
                              isActive: _isPlayingMusic,
                              onTap: _toggleMusic,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isCinematicMode)
                Positioned(
                  bottom: 15,
                  left: 24,
                  right: 24,
                  child: FadeTransition(
                    opacity: _uiFadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.25),
                        end: Offset.zero,
                      ).animate(_uiFadeAnimation),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentIndex > 0)
                            _buildProButton(
                              label: 'السابق',
                              icon: Icons.arrow_back_ios_new_rounded,
                              isPrimary: false,
                              accentColor: currentPage.themeAccent,
                              onPressed: () => _changePage(_currentIndex - 1),
                            )
                          else
                            const SizedBox(width: 110),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_pages.length, (index) {
                              final isSelected = index == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: isSelected ? 26 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? currentPage.themeAccent
                                      : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                          _buildProButton(
                            label: _currentIndex == 0
                                ? 'ابدأ الرحلة'
                                : (_currentIndex == _pages.length - 1
                                    ? 'إعادة الرحلة'
                                    : 'التالي'),
                            icon: _currentIndex == _pages.length - 1
                                ? Icons.replay_rounded
                                : Icons.arrow_forward_ios_rounded,
                            isPrimary: true,
                            accentColor: currentPage.themeAccent,
                            onPressed: () {
                              if (_currentIndex == _pages.length - 1) {
                                _changePage(0);
                              } else {
                                _changePage(_currentIndex + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecretNoteModal(JourneyPageData page) {
    final textController = TextEditingController(
      text: _userNotes[_currentIndex] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: _brownDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: page.themeAccent, width: 2),
            ),
            title: Row(
              children: [
                Icon(Icons.card_giftcard_rounded, color: page.themeAccent),
                const SizedBox(width: 8),
                Text(
                  'سر ${page.title}',
                  style: TextStyle(
                    color: page.themeAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.secretNote,
                  style: const TextStyle(
                    color: Color(0xFFFFF8E1),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'اكتب انطباعك أو ذكراك هنا عزيزي...',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: page.themeAccent.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _shareMemoryCard(page),
                icon: Icon(Icons.share_rounded, color: page.themeAccent),
                label: Text('مشاركة البطاقة',
                    style: TextStyle(color: page.themeAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: page.themeAccent,
                ),
                onPressed: () {
                  setState(() {
                    _userNotes[_currentIndex] = textController.text;
                  });
                  Navigator.pop(context);
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareMemoryCard(JourneyPageData page) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _brownMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: page.themeAccent, width: 2),
          ),
          title: Text('🎴 بطاقة الذكرى الخاصة بك',
              style: TextStyle(color: page.themeAccent, fontSize: 16)),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _brownDark,
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: page.themeAccent.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.title,
                  style: TextStyle(
                      color: page.themeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const Divider(color: _brownLight),
                const SizedBox(height: 8),
                Text(
                  '"${_userNotes[_currentIndex] ?? page.message}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: TextStyle(color: page.themeAccent)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _brownDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🏆 قائمة الألقاب والإنجازات',
                  style: TextStyle(
                    color: _goldWarm,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _brownMedium.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('اللقب',
                            style: TextStyle(
                                color: _goldWarm,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('الحالة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _goldWarm,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.builder(
                    itemCount: _achievements.length,
                    itemBuilder: (context, index) {
                      final item = _achievements[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              item.isUnlocked ? _goldWarm : _brownLight,
                          child: Icon(item.icon,
                              color:
                                  item.isUnlocked ? Colors.black : Colors.grey),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: item.isUnlocked ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(item.description,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                        trailing: item.isUnlocked
                            ? const Icon(Icons.check_circle_rounded,
                                color: Colors.green)
                            : const Icon(Icons.lock_rounded,
                                color: Colors.grey),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMapModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: _brownDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              border: Border(top: BorderSide(color: _goldWarm, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🗺️ خريطة مسار الرحلة',
                  style: TextStyle(
                    color: _goldWarm,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      final isCompleted = _completedSteps.contains(index);
                      final isCurrent = index == _currentIndex;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent
                              ? page.themeAccent
                              : (isCompleted ? _brownLight : _brownDark),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          page.title,
                          style: TextStyle(
                            color: isCurrent ? page.themeAccent : Colors.white,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          page.subtitle,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: isCompleted
                            ? const Icon(Icons.star_rounded, color: _goldWarm)
                            : const Icon(Icons.lock_clock_rounded,
                                color: Colors.grey),
                        onTap: () {
                          Navigator.pop(context);
                          _changePage(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullImageGallery(JourneyPageData page) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.asset(
                    page.imagePath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackBackground(page),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCompletionCertificate() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: _brownDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: _goldWarm, width: 2.5),
            ),
            title: const Center(
              child: Text(
                '👑 شهادة إتمام الرحلة',
                style: TextStyle(
                  color: _goldWarm,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded,
                    color: _goldWarm, size: 55),
                const SizedBox(height: 10),
                const Text(
                  'تهانينا يا بطل! لقد أتممت كافة محطات الرحلة بنجاح.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'عدد الانطباعات المدونة: ${_userNotes.length}',
                  style:
                      const TextStyle(color: Color(0xFFE2CBB4), fontSize: 12),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldWarm,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'إغلاق والاحتفال',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // أزرار التحكم الدائرية العلوية بتصميم المودرن النيون
  Widget _buildHeaderCircleButton({
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isActive = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: accentColor.withValues(alpha: 0.3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _brownMedium.withValues(alpha: 0.55),
                border: Border.all(
                  color: isActive
                      ? accentColor.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.14),
                  width: 1.4,
                ),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? accentColor : Colors.white54,
                size: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // زرار يدوي لإظهار لقب المحطة الحالية بدل ما يظهر تلقائي
  Widget _buildTitleRevealButton(JourneyPageData page) {
    final achievement = _achievements[_currentIndex];
    final isUnlocked = achievement.isUnlocked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap:
            isUnlocked ? null : () => _unlockAchievementForPage(_currentIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isUnlocked
                ? page.themeAccent.withValues(alpha: 0.16)
                : page.themeAccent.withValues(alpha: 0.32),
            border: Border.all(
              color: page.themeAccent.withValues(alpha: 0.75),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUnlocked
                    ? Icons.emoji_events_rounded
                    : Icons.lock_open_rounded,
                size: 14,
                color: page.themeAccent,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  isUnlocked
                      ? 'لقبك: ${achievement.title}'
                      : 'إظهار لقب المحطة',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: page.themeAccent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(JourneyPageData page, {Key? key}) {
    return Material(
      key: key,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showSecretNoteModal(page),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 290),
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
                  decoration: BoxDecoration(
                    color: _brownDark.withValues(alpha: 0.55),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: page.themeAccent.withValues(alpha: 0.55),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: page.themeAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 34,
                        height: 2.4,
                        decoration: BoxDecoration(
                          color: page.themeAccent.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TypewriterText(
                        key: ValueKey<String>('typewriter_${page.id}'),
                        text: page.message,
                        textAlign: TextAlign.center,
                        duration: Duration(
                          milliseconds:
                              (page.message.length * 45).clamp(900, 3000),
                        ),
                        style: const TextStyle(
                          color: Color(0xFFF5F5F5),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 13,
                              color: page.themeAccent.withValues(alpha: 0.85)),
                          const SizedBox(width: 4),
                          Text(
                            'اضغط لاكتشاف سر المحطة',
                            style: TextStyle(
                              color: page.themeAccent.withValues(alpha: 0.85),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTitleRevealButton(page),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -16,
              right: 18,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brownDark,
                  border: Border.all(color: page.themeAccent, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: page.themeAccent.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: page.themeAccent, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // أزرار التنقل الرئيسية المحدثة بظلال متدرجة وحواف لمّاعة
  Widget _buildProButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required Color accentColor,
    required VoidCallback onPressed,
  }) {
    final List<Color> primaryGradient = [
      accentColor,
      Color.lerp(accentColor, const Color(0xFF8B5E34), 0.35)!,
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: isPrimary
                ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                : ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: isPrimary
                    ? LinearGradient(
                        colors: primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isPrimary ? null : _brownMedium.withValues(alpha: 0.5),
                border: Border.all(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.45)
                      : accentColor.withValues(alpha: 0.55),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPrimary
                        ? accentColor.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.35),
                    blurRadius: isPrimary ? 14 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      color: isPrimary ? const Color(0xFF1A0F0A) : accentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPrimary
                          ? Colors.black.withValues(alpha: 0.15)
                          : accentColor.withValues(alpha: 0.18),
                    ),
                    child: Icon(
                      icon,
                      size: 13,
                      color: isPrimary ? const Color(0xFF1A0F0A) : accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBackground(JourneyPageData page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _brownDark,
            page.themeAccent.withValues(alpha: 0.25),
            _brownDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.landscape_rounded,
                size: 80, color: page.themeAccent.withValues(alpha: 0.6)),
            const SizedBox(height: 10),
            Text(
              page.title,
              style: TextStyle(
                  color: page.themeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackCharacter(JourneyPageData page) {
    return Container(
      decoration: BoxDecoration(
        color: page.themeAccent.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: page.themeAccent, width: 2),
      ),
      child: Icon(
        Icons.person_pin_circle_rounded,
        size: 55,
        color: page.themeAccent,
      ),
    );
  }
}

// ويدجت بتظهر النص حرف بحرف بانيميشن متتابع (تأثير الآلة الكاتبة)
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration duration;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.duration = const Duration(milliseconds: 1600),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _charCount = _buildCharAnimation();
    if (widget.onComplete != null) {
      _controller.addStatusListener(_handleStatus);
    }
    _controller.forward();
  }

  Animation<int> _buildCharAnimation() {
    return StepTween(begin: 0, end: widget.text.length).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onComplete?.call();
    }
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.duration = widget.duration;
      setState(() {
        _charCount = _buildCharAnimation();
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final count = _charCount.value.clamp(0, widget.text.length);
        return Text(
          widget.text.substring(0, count),
          textAlign: widget.textAlign,
          style: widget.style,
        );
      },
    );
  }
}

class TouchBubblePainter extends CustomPainter {
  final List<TouchBubble> bubbles;

  TouchBubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color.withValues(alpha: bubble.opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final fillPaint = Paint()
        ..color = bubble.color
            .withValues(alpha: (bubble.opacity * 0.3).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(bubble.position, bubble.radius, fillPaint);
      canvas.drawCircle(bubble.position, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant TouchBubblePainter oldDelegate) => true;
}

class BackgroundParticlesPainter extends CustomPainter {
  final double animationValue;
  final Color particleColor;

  BackgroundParticlesPainter(this.animationValue, this.particleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 35; i++) {
      final x = random.nextDouble() * size.width;
      final speed = random.nextDouble() * 0.5 + 0.2;
      final initialY = random.nextDouble() * size.height;
      final y =
          (initialY - (animationValue * size.height * speed)) % size.height;
      final particleSize = random.nextDouble() * 3 + 1;
      final opacity = (math.sin((animationValue * math.pi * 2) + i) + 1) / 2;

      paint.color = particleColor.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundParticlesPainter oldDelegate) => true;
}

class ConfettiPainter extends CustomPainter {
  final double progress;

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);
    final colors = [
      const Color(0xFFE5B869),
      const Color(0xFFD48C46),
      const Color(0xFFF0C265),
      const Color(0xFFC88242),
      Colors.white,
    ];

    for (int i = 0; i < 70; i++) {
      final color = colors[random.nextInt(colors.length)];
      final startX = size.width / 2;
      final startY = size.height / 2;

      final angle = random.nextDouble() * 2 * math.pi;
      final speed = random.nextDouble() * 300 + 100;
      final distance = speed * progress;

      final x = startX + math.cos(angle) * distance;
      final y =
          startY + math.sin(angle) * distance + (progress * progress * 200);

      final particleSize = random.nextDouble() * 6 + 4;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
