import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../../admin/data/models/lawyer.dart' as model;
import '../../data/services/lawyer_api_service.dart';

// Removed mock class; now reading real lawyers from storage

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

  // ignore: unused_field
  List<model.Lawyer> _allLawyers = <model.Lawyer>[];
  List<model.Lawyer> _filtered = <model.Lawyer>[];
  bool _loading = true;

  bool _showFilter = false;
  String _selectedCategory = 'Tất cả';
  void _applyFilter() {
    if (_selectedCategory == 'Tất cả') {
      _filtered = List<model.Lawyer>.from(_allLawyers);
    } else {
      final String keyword = _selectedCategory.toLowerCase();
      _filtered = _allLawyers.where((model.Lawyer l) {
        final String spec = l.specialization.toLowerCase();
        return spec.contains(keyword);
      }).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // Try to load from API first
      final response = await LawyerApiService.getLawyers();
      if (response.statusCode == 200) {
        // Swagger may return either a raw list or a wrapped object
        final dynamic data = response.data;
        List<dynamic> lawyersData;
        if (data is List) {
          lawyersData = data;
        } else if (data is Map<String, dynamic>) {
          // common keys: 'result', 'data', 'payload'
          final dynamic inner =
              data['result'] ?? data['data'] ?? data['payload'];
          if (inner is List) {
            lawyersData = inner;
          } else {
            // fallback: try to find first list value in map
            final List<dynamic>? firstList = data.values.firstWhere(
              (v) => v is List,
              orElse: () => <dynamic>[],
            ) as List<dynamic>?;
            lawyersData = firstList ?? <dynamic>[];
          }
        } else {
          lawyersData = <dynamic>[];
        }

        final lawyers = lawyersData
            .whereType<Map<String, dynamic>>()
            .map((json) => model.Lawyer.fromJson(json))
            .toList();
        setState(() {
          _allLawyers = lawyers;
          _filtered = lawyers;
          _selectedCategory = 'Tất cả';
          _loading = false;
        });
        return;
      }
    } catch (e) {
      print('API load failed, falling back to local storage: $e');
    }

    // Fallback to local storage
    final list = await UserStorageService.getLawyers();
    setState(() {
      _allLawyers = list;
      _filtered = list;
      _selectedCategory = 'Tất cả';
      _loading = false;
    });
  }

  List<model.Lawyer> get _filteredLawyers => _filtered;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.filter_list, color: primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedCategory == 'Tất cả'
                              ? 'Lọc theo dịch vụ'
                              : 'Dịch vụ: $_selectedCategory',
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(_showFilter ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey.shade600),
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
                      _selectedCategory = c;
                      _showFilter = false; // thu gọn sau khi chọn
                      _applyFilter();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                          color:
                              selected ? primaryColor : Colors.grey.shade300),
                    ),
                    backgroundColor: Colors.white,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _showFilter
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
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
  final List<model.Lawyer> lawyers;
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
        final model.Lawyer lawyer = lawyers[index];
        return _LawyerCard(lawyer: lawyer, primaryColor: primaryColor);
      },
    );
  }
}

class _LawyerCard extends StatelessWidget {
  final model.Lawyer lawyer;
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
                child: Icon(Icons.person, color: primaryColor, size: 28),
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
                      lawyer.specialization,
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
                '${lawyer.experienceYears} năm kinh nghiệm',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.star_rounded,
                  size: 16, color: Color(0xFFFFB300)),
              const SizedBox(width: 6),
              Text('4.6',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.push('/lawyer/${lawyer.id}/detail', extra: {
                  'lawyerName': lawyer.name,
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                'Xem chi tiết',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
