class GameRating {
  final double averageOutOf5;
  final int reviewsCount;

  const GameRating({required this.averageOutOf5, required this.reviewsCount});

  static const empty = GameRating(averageOutOf5: 0.0, reviewsCount: 0);
}
