import 'package:flutter/material.dart';

/// Test page để kiểm tra responsive design với đơn vị tương đối
class ResponsiveTestPage extends StatelessWidget {
  const ResponsiveTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Test - Relative Units'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen size info
            _buildScreenInfo(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            
            // Responsive text test
            _buildTextTest(screenWidth, isTablet),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            
            // Responsive button test
            _buildButtonTest(screenWidth, screenHeight, isTablet),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            
            // Responsive card test
            _buildCardTest(screenWidth, screenHeight, isTablet),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            
            // Responsive layout test
            _buildLayoutTest(screenWidth, screenHeight, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenInfo(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin màn hình - Đơn vị tương đối',
            style: TextStyle(
              fontSize: screenWidth * 0.045, // 4.5% of screen width
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // 1% of screen height
          Text(
            'Chiều rộng: ${screenWidth.toStringAsFixed(1)}px',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.white70,
            ),
          ),
          Text(
            'Chiều cao: ${screenHeight.toStringAsFixed(1)}px',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.white70,
            ),
          ),
          Text(
            'Loại thiết bị: ${_getDeviceType(screenWidth)}',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.white70,
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // 1% of screen height
          Text(
            'Sử dụng đơn vị % thay vì px cố định',
            style: TextStyle(
              fontSize: screenWidth * 0.03, // 3% of screen width
              color: Colors.white60,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTest(double screenWidth, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Text Responsive - Đơn vị %',
          style: TextStyle(
            fontSize: screenWidth * (isTablet ? 0.06 : 0.05), // 6% for tablet, 5% for mobile
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: screenWidth * 0.02), // 2% of screen width
        Text(
          'Đây là text test với đơn vị tương đối. Text này sẽ tự động thay đổi kích thước theo tỷ lệ màn hình, tránh nhảy chữ.',
          style: TextStyle(
            fontSize: screenWidth * (isTablet ? 0.04 : 0.035), // 4% for tablet, 3.5% for mobile
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonTest(double screenWidth, double screenHeight, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Button Responsive - Đơn vị %',
          style: TextStyle(
            fontSize: screenWidth * (isTablet ? 0.06 : 0.05), // 6% for tablet, 5% for mobile
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: screenHeight * 0.02), // 2% of screen height
        isTablet
            ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% of screen height
                      ),
                      child: Text(
                        'Button 1',
                        style: TextStyle(fontSize: screenWidth * 0.04), // 4% of screen width
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04), // 4% of screen width
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% of screen height
                      ),
                      child: Text(
                        'Button 2',
                        style: TextStyle(fontSize: screenWidth * 0.04), // 4% of screen width
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% of screen height
                      ),
                      child: Text(
                        'Button 1',
                        style: TextStyle(fontSize: screenWidth * 0.035), // 3.5% of screen width
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% of screen height
                      ),
                      child: Text(
                        'Button 2',
                        style: TextStyle(fontSize: screenWidth * 0.035), // 3.5% of screen width
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildCardTest(double screenWidth, double screenHeight, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Card Responsive - Đơn vị %',
          style: TextStyle(
            fontSize: screenWidth * (isTablet ? 0.06 : 0.05), // 6% for tablet, 5% for mobile
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: screenHeight * 0.02), // 2% of screen height
        isTablet
            ? Row(
                children: [
                  Expanded(
                    child: _buildTestCard('Card 1', Icons.star),
                  ),
                  SizedBox(width: screenWidth * 0.04), // 4% of screen width
                  Expanded(
                    child: _buildTestCard('Card 2', Icons.favorite),
                  ),
                  SizedBox(width: screenWidth * 0.04), // 4% of screen width
                  Expanded(
                    child: _buildTestCard('Card 3', Icons.thumb_up),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildTestCard('Card 1', Icons.star),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  _buildTestCard('Card 2', Icons.favorite),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  _buildTestCard('Card 3', Icons.thumb_up),
                ],
              ),
      ],
    );
  }

  Widget _buildTestCard(String title, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: screenWidth * 0.08, // 8% of screen width
            color: const Color(0xFF1E3A8A),
          ),
          SizedBox(height: screenHeight * 0.01), // 1% of screen height
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.04, // 4% of screen width
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTest(double screenWidth, double screenHeight, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Layout Responsive - Đơn vị %',
          style: TextStyle(
            fontSize: screenWidth * (isTablet ? 0.06 : 0.05), // 6% for tablet, 5% for mobile
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        SizedBox(height: screenHeight * 0.02), // 2% of screen height
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            isTablet
                ? 'Layout này được tối ưu cho màn hình lớn (tablet/desktop) với đơn vị %'
                : 'Layout này được tối ưu cho màn hình nhỏ (mobile) với đơn vị %',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _getDeviceType(double screenWidth) {
    if (screenWidth > 1200) {
      return 'Desktop';
    } else if (screenWidth > 600) {
      return 'Tablet';
    } else {
      return 'Mobile';
    }
  }
}
