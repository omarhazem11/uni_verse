class TileTier {
  final double padding;
  final double iconContainerSize;
  final double iconRadius;
  final double iconGlyphSize;
  final double iconTitleGap;
  final double titleSize;
  final double titleSubtitleGap;
  final double subtitleSize;

  const TileTier({
    required this.padding,
    required this.iconContainerSize,
    required this.iconRadius,
    required this.iconGlyphSize,
    required this.iconTitleGap,
    required this.titleSize,
    required this.titleSubtitleGap,
    required this.subtitleSize,
  });

  // xs: iPhone SE and similarly narrow phones (tile width < 170).
  static const xs = TileTier(
    padding: 10,
    iconContainerSize: 40,
    iconRadius: 12,
    iconGlyphSize: 20,
    iconTitleGap: 8,
    titleSize: 16,
    titleSubtitleGap: 2,
    subtitleSize: 11.5,
  );

  // sm: iPhone 12/13/14 standard width (170-186).
  static const sm = TileTier(
    padding: 11,
    iconContainerSize: 48,
    iconRadius: 13,
    iconGlyphSize: 24,
    iconTitleGap: 9,
    titleSize: 19,
    titleSubtitleGap: 2,
    subtitleSize: 13,
  );

  // md: iPhone 14/15 Pro Max and similar large phones (186-215).
  static const md = TileTier(
    padding: 12,
    iconContainerSize: 58,
    iconRadius: 15,
    iconGlyphSize: 29,
    iconTitleGap: 10,
    titleSize: 21,
    titleSubtitleGap: 3,
    subtitleSize: 14.5,
  );

  // lg: foldables and small tablets in portrait (215-300).
  static const lg = TileTier(
    padding: 14,
    iconContainerSize: 68,
    iconRadius: 17,
    iconGlyphSize: 34,
    iconTitleGap: 11,
    titleSize: 24,
    titleSubtitleGap: 3,
    subtitleSize: 16.5,
  );

  // xl: iPad and larger tablets (>= 300).
  static const xl = TileTier(
    padding: 16,
    iconContainerSize: 80,
    iconRadius: 19,
    iconGlyphSize: 40,
    iconTitleGap: 12,
    titleSize: 30,
    titleSubtitleGap: 4,
    subtitleSize: 20,
  );

  static TileTier forWidth(double width) {
    if (width < 170) return xs;
    if (width < 186) return sm;
    if (width < 215) return md;
    if (width < 300) return lg;
    return xl;
  }
}
