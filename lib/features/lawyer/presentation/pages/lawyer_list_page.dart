import 'package:flutter/material.dart';

class _Lawyer {
  final String name;
  final String specialty;
  final int yearsOfExperience;
  final double rating;
  final String photoAsset;

  const _Lawyer({
    required this.name,
    required this.specialty,
    required this.yearsOfExperience,
    required this.rating,
    required this.photoAsset,
  });
}

class LawyerListPage extends StatefulWidget {
  const LawyerListPage({super.key});

  @override
  State<LawyerListPage> createState() => _LawyerListPageState();
}

class _LawyerListPageState extends State<LawyerListPage> {
  final Color primaryColor = const Color(0xFF1E3A8A);

  final List<String> categories = <String>[
    'Tất cả',
    'Tư vấn pháp lý',
    'Hợp đồng',
    'Đại diện',
    'Gia đình',
  ];

  late final Map<String, List<_Lawyer>> dataByCategory;
  late final List<_Lawyer> allLawyers;

  bool _showFilter = false;
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    dataByCategory = <String, List<_Lawyer>>{
      'Tư vấn pháp lý': const <_Lawyer>[
        _Lawyer(
          name: 'Nguyễn Minh Anh',
          specialty: 'Tư vấn pháp lý',
          yearsOfExperience: 12,
          rating: 4.8,
          photoAsset: 'assets/images/lawyers/lawyer1.png',
        ),
        _Lawyer(
          name: 'Trần Quốc Bảo',
          specialty: 'Tư vấn pháp lý',
          yearsOfExperience: 8,
          rating: 4.5,
          photoAsset: 'assets/images/lawyers/lawyer2.png',
        ),
      ],
      'Hợp đồng': const <_Lawyer>[
        _Lawyer(
          name: 'Lê Thu Hà',
          specialty: 'Soạn thảo hợp đồng',
          yearsOfExperience: 10,
          rating: 4.7,
          photoAsset: 'assets/images/lawyers/lawyer3.png',
        ),
        _Lawyer(
          name: 'Phạm Duy Khang',
          specialty: 'Thẩm định hợp đồng',
          yearsOfExperience: 9,
          rating: 4.6,
          photoAsset: 'assets/images/lawyers/lawyer4.png',
        ),
      ],
      'Đại diện': const <_Lawyer>[
        _Lawyer(
          name: 'Võ Hoài Nam',
          specialty: 'Đại diện pháp lý',
          yearsOfExperience: 11,
          rating: 4.9,
          photoAsset: 'assets/images/lawyers/lawyer5.png',
        ),
        _Lawyer(
          name: 'Đặng Thùy Linh',
          specialty: 'Tranh tụng',
          yearsOfExperience: 7,
          rating: 4.4,
          photoAsset: 'assets/images/lawyers/lawyer6.png',
        ),
      ],
      'Gia đình': const <_Lawyer>[
        _Lawyer(
          name: 'Ngô Bích Phương',
          specialty: 'Luật gia đình',
          yearsOfExperience: 13,
          rating: 4.8,
          photoAsset: 'assets/images/lawyers/lawyer7.png',
        ),
        _Lawyer(
          name: 'Bùi Hữu Tài',
          specialty: 'Tư vấn hôn nhân',
          yearsOfExperience: 6,
          rating: 4.3,
          photoAsset: 'assets/images/lawyers/lawyer8.png',
        ),
      ],
    };
    allLawyers = <_Lawyer>[
      ...dataByCategory['Tư vấn pháp lý']!,
      ...dataByCategory['Hợp đồng']!,
      ...dataByCategory['Đại diện']!,
      ...dataByCategory['Gia đình']!,
    ];
  }

  List<_Lawyer> get _filteredLawyers {
    if (_selectedCategory == 'Tất cả') return allLawyers;
    return dataByCategory[_selectedCategory] ?? <_Lawyer>[];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luật sư'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _showFilter = !_showFilter),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.filter_list, color: primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedCategory == 'Tất cả'
                              ? 'Lọc theo dịch vụ'
                              : 'Dịch vụ: $_selectedCategory',
                          style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(_showFilter ? Icons.expand_less : Icons.expand_more, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((String c) {
                  final bool selected = _selectedCategory == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? primaryColor : Colors.grey.shade800,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = c;
                        _showFilter = false; // thu gọn sau khi chọn
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: selected ? primaryColor : Colors.grey.shade300),
                    ),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _showFilter ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _LawyerGrid(
              lawyers: _filteredLawyers,
              primaryColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LawyerGrid extends StatelessWidget {
  final List<_Lawyer> lawyers;
  final Color primaryColor;

  const _LawyerGrid({
    required this.lawyers,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return GridView.builder(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: isTablet ? 20 : 12,
        mainAxisSpacing: isTablet ? 20 : 12,
        mainAxisExtent: isTablet ? 230 : 210,
      ),
      itemCount: lawyers.length,
      itemBuilder: (BuildContext context, int index) {
        final _Lawyer lawyer = lawyers[index];
        return _LawyerCard(lawyer: lawyer, primaryColor: primaryColor);
      },
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final _Lawyer lawyer;
  final Color primaryColor;

  const _LawyerCard({
    required this.lawyer,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  lawyer.photoAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext _, Object __, StackTrace? ___) {
                    return Icon(Icons.person, color: primaryColor, size: 28);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      lawyer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lawyer.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(Icons.badge, size: 18, color: primaryColor),
              const SizedBox(width: 6),
              Text(
                '${lawyer.yearsOfExperience} năm kinh nghiệm',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              ...List<Widget>.generate(5, (int i) {
                final bool filled = i < lawyer.rating.floor();
                final bool half = !filled && (i + 0.5) < lawyer.rating;
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    half ? Icons.star_half_rounded : Icons.star_rounded,
                    size: 16,
                    color: filled || half ? const Color(0xFFFFB300) : Colors.grey.shade300,
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text(
                lawyer.rating.toStringAsFixed(1),
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                'Đặt lịch',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
