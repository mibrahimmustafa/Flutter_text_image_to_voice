class PresetDemoPhoto {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final String extractedText;

  const PresetDemoPhoto({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.extractedText,
  });

  static const List<PresetDemoPhoto> samples = [
    PresetDemoPhoto(
      id: 'book_quote',
      title: 'Classic Literature Excerpt',
      category: 'Book Page',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife. However little known the feelings or views of such a man may be on his first entering a neighbourhood.',
    ),
    PresetDemoPhoto(
      id: 'billboard_quote',
      title: 'Inspirational Street Sign',
      category: 'Signboard',
      imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'The future belongs to those who believe in the beauty of their dreams. Start each day with a grateful heart, work with relentless passion, and never surrender your vision.',
    ),
    PresetDemoPhoto(
      id: 'cafe_menu',
      title: 'Artisan Cafe Special',
      category: 'Menu Board',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'Daily Special: Double-shot Velvet Espresso with caramel drizzle, paired with freshly baked almond croissants and wild honey. Brewed with love every morning.',
    ),
    PresetDemoPhoto(
      id: 'tech_news',
      title: 'Science & AI Breakthrough',
      category: 'Article',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&auto=format&fit=crop&q=80',
      extractedText:
          'Breakthrough in neural voice synthesis allows real-time text-to-speech conversion from any visual document with human-level natural prosody and emotional cadence.',
    ),
  ];
}
