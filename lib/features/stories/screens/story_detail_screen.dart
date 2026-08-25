import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/stories_data.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _showText = false; // false = فيديو، true = نص

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1623),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.story.title,
          style: GoogleFonts.amiri(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (widget.story.type == StoryType.both)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: const Color(0xFF132033),
              onSelected: (value) {
                setState(() {
                  _showText = value == 'text';
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'video',
                  child: Row(
                    children: [
                      Icon(Icons.play_circle, color: Colors.red),
                      SizedBox(width: 8),
                      Text('مشاهدة الفيديو', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'text',
                  child: Row(
                    children: [
                      Icon(Icons.menu_book, color: Colors.green),
                      SizedBox(width: 8),
                      Text('قراءة القصة', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // أزرار التبديل
          if (widget.story.type == StoryType.both)
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF132033),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showText = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_showText ? Colors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle, color: !_showText ? Colors.white : Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              'فيديو',
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: !_showText ? Colors.white : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showText = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _showText ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book, color: _showText ? Colors.white : Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'قراءة',
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _showText ? Colors.white : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // المحتوى
          Expanded(
            child: _showText && widget.story.type != StoryType.video
                ? _buildTextContent()
                : _buildVideoContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة المصغرة
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.story.thumbnailUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          
          // العنوان والوصف
          Text(
            widget.story.title,
            style: GoogleFonts.amiri(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            widget.story.description,
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: Colors.white70,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 20),
          
          // الوسوم
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.story.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB8922A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.amiri(
                    fontSize: 13,
                    color: const Color(0xFFB8922A),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // زر المشاهدة
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openVideo(),
              icon: const Icon(Icons.play_circle, size: 24),
              label: Text(
                'مشاهدة الفيديو على يوتيوب',
                style: GoogleFonts.amiri(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نص القصة (مثال - يجب استبداله بالنص الحقيقي)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB8922A).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story.title,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'هنا سيتم وضع نص القصة كاملاً...\n\n'
                  'يمكنك إضافة النص الكامل للقصة في حقل textContent في البيانات.\n\n'
                  'مثال:\n'
                  'في يوم من الأيام...\n\n'
                  'وهكذا تستمر القصة حتى نهايتها...',
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    color: Colors.white,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // زر الفيديو أيضاً
          if (widget.story.type == StoryType.both)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openVideo(),
                icon: const Icon(Icons.play_circle, size: 20),
                label: Text(
                  'أو شاهد الفيديو',
                  style: GoogleFonts.amiri(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openVideo() async {
    if (widget.story.videoUrl != null) {
      final Uri url = Uri.parse(widget.story.videoUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الفيديو'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
