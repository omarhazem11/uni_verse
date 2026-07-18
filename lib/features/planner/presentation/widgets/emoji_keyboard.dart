import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// Curated emoji set organised by category. Add/remove freely — nothing else
// references this file, so changes never break existing saved items.
const _categories = <({String label, String icon, List<String> emojis})>[
  (
    label: 'Smileys',
    icon: '😀',
    emojis: [
      '😀','😃','😄','😁','😆','😅','🤣','😂','🙂','🙃',
      '😉','😊','😇','🥰','😍','🤩','😘','😗','😚','😙',
      '😋','😛','😜','🤪','😝','🤑','🤗','🤔','🤭','😐',
      '😑','😶','😏','😒','🙄','😬','😔','😪','🤤','😴',
      '😷','🤒','🤕','🥳','🥺','😭','😢','😤','😠','😡',
    ],
  ),
  (
    label: 'Study',
    icon: '📚',
    emojis: [
      '📚','📖','✏️','📝','🖊️','🖋️','📓','📔','📒','📕',
      '📗','📘','📙','📑','📄','📃','📋','🗒️','📌','📍',
      '📎','🖇️','📐','📏','🔬','🔭','🖥️','💻','🖨️','⌨️',
      '🖱️','💾','💿','📀','🧮','🔋','📡','🎓','🏫','✂️',
    ],
  ),
  (
    label: 'Work',
    icon: '💼',
    emojis: [
      '💼','📊','📈','📉','🗂️','🗃️','📂','📁','🗄️','🖹',
      '📧','📨','📩','📤','📥','📦','📬','📮','📯','📣',
      '📢','🔔','🔕','💬','💭','🗯️','📞','☎️','📟','📠',
      '🤝','👔','🏢','🏦','🏛️','🏗️','⚙️','🔧','🔩','🛠️',
    ],
  ),
  (
    label: 'Food',
    icon: '🍔',
    emojis: [
      '🍔','🍕','🌮','🌯','🥗','🥘','🍲','🍜','🍝','🍛',
      '🍣','🍱','🍤','🍙','🍚','🥫','🧆','🥙','🥪','🌭',
      '🍟','🧀','🥚','🍳','🥞','🥓','🥩','🍗','🍖','🌽',
      '☕','🍵','🥤','🧃','🥛','🍺','🍷','🥂','🍹','🧋',
      '🍰','🎂','🍮','🍭','🍬','🍫','🍩','🍪','🍦','🍨',
    ],
  ),
  (
    label: 'Fitness',
    icon: '🏃',
    emojis: [
      '🏃','🚶','🧘','🏋️','🤸','🚴','🏊','⛹️','🤾','🏇',
      '🧗','🤺','🥊','🥋','⚽','🏀','🏈','⚾','🎾','🏐',
      '🏉','🎱','🏓','🏸','🥅','🎯','🏹','🛹','🛼','🤿',
      '⛷️','🏂','🪂','💪','🦵','🧠','❤️','🫀','🩺','💊',
    ],
  ),
  (
    label: 'Life',
    icon: '🏠',
    emojis: [
      '🏠','🛁','🚿','🛏️','🪑','🛋️','🪞','🚪','🪟','🛒',
      '🧹','🧺','🧻','🪣','🧼','🧽','🪠','🔑','🗝️','🔒',
      '💡','🔦','🕯️','🛏️','🧸','🎀','🎁','🎊','🎉','🎈',
      '👕','👗','👠','👟','🧢','👒','🎒','💍','💎','👜',
    ],
  ),
  (
    label: 'Nature',
    icon: '🌿',
    emojis: [
      '🌿','🌱','🌲','🌳','🌴','🪴','🌵','🎋','🎍','🍀',
      '🌺','🌸','🌼','🌻','🌹','💐','🍁','🍂','🍃','🌾',
      '☀️','🌤️','⛅','🌈','🌧️','⛈️','❄️','🌊','🔥','💧',
      '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🦁',
    ],
  ),
  (
    label: 'Creative',
    icon: '🎨',
    emojis: [
      '🎨','🖌️','✂️','📷','📸','🎬','🎥','🎞️','📽️','🎦',
      '🎵','🎶','🎸','🎹','🎺','🎻','🥁','🎤','🎧','🎼',
      '🎭','🎪','🎠','🎡','🎢','🎯','🎲','🎮','🕹️','🎰',
      '🎻','🪗','🪘','🎷','🪕','🎙️','📻','📺','📱','💻',
    ],
  ),
];

/// A full emoji keyboard shown as a modal bottom sheet.
/// Call [show] to display it; [onPicked] is called with the selected emoji.
class EmojiKeyboard extends StatefulWidget {
  final ValueChanged<String> onPicked;

  const EmojiKeyboard({super.key, required this.onPicked});

  static Future<void> show(BuildContext context, ValueChanged<String> onPicked) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EmojiKeyboard(onPicked: onPicked),
    );
  }

  @override
  State<EmojiKeyboard> createState() => _EmojiKeyboardState();
}

class _EmojiKeyboardState extends State<EmojiKeyboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Category tab bar
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.violet,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              for (final cat in _categories)
                Tab(child: Text(cat.icon, style: const TextStyle(fontSize: 22))),
            ],
          ),

          // Emoji grids
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                for (final cat in _categories)
                  GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: cat.emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = cat.emojis[index];
                      return GestureDetector(
                        onTap: () {
                          widget.onPicked(emoji);
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
