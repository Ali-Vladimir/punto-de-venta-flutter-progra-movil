import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../services/auth_service.dart';
import '../../../services/employee_service.dart';
import '../../../services/sale_service.dart';
import '../../../models/sale_dto.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final EmployeeService _employeeService = EmployeeService();
  final SaleService _saleService = SaleService();

  final Color primaryColor = const Color(0xFF1A237E);
  final Color accentColor = const Color(0xFF00BFA5);

  bool _isLoading = true;
  DateTimeRange? _dateRange;
  Map<String, dynamic>? _employeeStats;
  List<SaleDTO> _allSales = [];
  
  // Mock data
  final List<Map<String, dynamic>> _salesByDay = [];
  final List<Map<String, dynamic>> _salesByCategory = [];
  final List<Map<String, dynamic>> _topProducts = [];
  final List<Map<String, dynamic>> _employeesByPosition = [];
  final List<Map<String, dynamic>> _topEmployees = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDateRange();
    _loadData();
  }

  void _initializeDateRange() {
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final companyId = _authService.currentCompanyId;
      if (companyId != null) {
        // Cargar datos en paralelo
        await Future.wait([
          _loadEmployeeStats(companyId),
          _loadSalesData(companyId),
        ]);
      }
      
      // Generate mock data with real sales data if available
      _generateDataFromFirebase();
    } catch (e) {
      debugPrint('Error loading data: $e');
      _generateMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEmployeeStats(String companyId) async {
    final stats = await _employeeService.getEmployeeStats(companyId);
    setState(() {
      _employeeStats = stats;
    });
  }

  Future<void> _loadSalesData(String companyId) async {
    final sales = await _saleService.getAll(companyId);
    setState(() {
      _allSales = sales;
    });
  }

  void _generateDataFromFirebase() {
    if (_allSales.isEmpty) {
      // Si no hay ventas, usar mock data
      _generateMockData();
      return;
    }

    // Generar datos de ventas por d\u00eda (últimos 7 días)
    _salesByDay.clear();
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final nextDate = targetDate.add(const Duration(days: 1));
      
      // Filtrar ventas del d\u00eda
      final daySales = _allSales.where((sale) {
        return sale.saleDate != null &&
               sale.saleDate!.isAfter(targetDate) &&
               sale.saleDate!.isBefore(nextDate);
      }).toList();
      
      // Calcular total del d\u00eda
      final dayTotal = daySales.fold(0.0, (sum, sale) => sum + (sale.total ?? 0.0));
      
      _salesByDay.add({
        'date': targetDate,
        'amount': dayTotal,
      });
    }

    // Si hay poca data de ventas, complementar con mock
    if (_salesByDay.every((day) => (day['amount'] as double) == 0)) {
      _generateMockData();
    } else {
      _generateMockCategoriesAndProducts();
    }
  }

  void _generateMockCategoriesAndProducts() {
    final random = math.Random();
    
    // Sales by category (mock data ya que no tenemos categorías en las ventas)
    _salesByCategory.clear();
    final categories = [
      {'name': 'Electrónica', 'color': Colors.blue},
      {'name': 'Ropa', 'color': Colors.green},
      {'name': 'Alimentos', 'color': Colors.orange},
      {'name': 'Hogar', 'color': Colors.red},
      {'name': 'Deportes', 'color': Colors.purple},
      {'name': 'Juguetes', 'color': Colors.pink},
    ];
    
    for (var cat in categories) {
      _salesByCategory.add({
        'category': cat['name'],
        'amount': 10000 + random.nextDouble() * 40000,
        'color': cat['color'],
      });
    }

    // Top products (mock data)
    _topProducts.clear();
    final products = ['Laptop HP', 'iPhone 15', 'Samsung TV', 'Nike Shoes', 'PlayStation 5'];
    for (var product in products) {
      _topProducts.add({
        'name': product,
        'quantity': 10 + random.nextInt(90),
        'revenue': 20000 + random.nextDouble() * 80000,
      });
    }
    _topProducts.sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

    // Employees data
    _generateEmployeesData();
  }

  void _generateEmployeesData() {
    final random = math.Random();
    
    // Employees by position - usar datos reales si existen
    _employeesByPosition.clear();
    if (_employeeStats != null && _employeeStats!['positionCounts'] != null) {
      final positionCounts = _employeeStats!['positionCounts'] as Map<String, dynamic>;
      final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.pink];
      int colorIndex = 0;
      
      positionCounts.forEach((position, count) {
        _employeesByPosition.add({
          'name': position,
          'count': count,
          'color': colors[colorIndex % colors.length],
        });
        colorIndex++;
      });
    } else {
      // Mock data si no hay datos reales
      final positions = [
        {'name': 'Vendedor', 'count': 8, 'color': Colors.blue},
        {'name': 'Cajero', 'count': 5, 'color': Colors.green},
        {'name': 'Gerente', 'count': 2, 'color': Colors.orange},
        {'name': 'Almacenista', 'count': 3, 'color': Colors.purple},
      ];
      
      for (var pos in positions) {
        _employeesByPosition.add(pos);
      }
    }

    // Top employees by sales (mock data - requeriría relación ventas-empleados)
    _topEmployees.clear();
    final employeeNames = ['Juan Pérez', 'María García', 'Carlos López', 'Ana Martínez', 'Luis Rodríguez'];
    for (var name in employeeNames) {
      _topEmployees.add({
        'name': name,
        'sales': 15 + random.nextInt(35),
        'amount': 50000 + random.nextDouble() * 150000,
      });
    }
    _topEmployees.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
  }

  void _generateMockData() {
    final random = math.Random();
    
    // Sales by day (last 7 days) - Solo si no hay datos reales
    if (_salesByDay.isEmpty) {
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        _salesByDay.add({
          'date': date,
          'amount': 5000 + random.nextDouble() * 15000,
        });
      }
    }

    // Generar el resto de datos mock
    _generateMockCategoriesAndProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Reportes y Estadísticas',
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onPressed: _selectDateRange,
            tooltip: 'Seleccionar rango de fechas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Ventas'),
            Tab(icon: Icon(Icons.people), text: 'Empleados'),
            Tab(icon: Icon(Icons.dashboard), text: 'General'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSalesTab(),
                _buildEmployeesTab(),
                _buildGeneralTab(),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    final totalSales = _salesByDay.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );
    final avgSales = totalSales / _salesByDay.length;
    final bestDay = _salesByDay.reduce((a, b) =>
        (a['amount'] as double) > (b['amount'] as double) ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Ventas',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalSales),
                Icons.trending_up,
                Colors.green,
              ).animate().fadeIn(duration: 400.ms).slideX(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Promedio/Día',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgSales),
                Icons.bar_chart,
                Colors.blue,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Mejor Día',
          '${DateFormat('dd/MM/yyyy').format(bestDay['date'])} - ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(bestDay['amount'])}',
          Icons.star,
          Colors.orange,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(),
        
        const SizedBox(height: 24),
        
        // Line chart - Sales by day
        _buildChartCard(
          'Ventas por Día',
          _buildSalesLineChart(),
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale(),
        
        const SizedBox(height: 24),
        
        // Bar chart - Sales by category
        _buildChartCard(
          'Ventas por Categoría',
          _buildSalesByCategoryChart(),
          height: 350,
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(),
        
        const SizedBox(height: 24),
        
        // Top products
        _buildTopProductsCard()
            .animate()
            .fadeIn(duration: 600.ms, delay: 500.ms)
            .slideY(),
      ],
    );
  }

  Widget _buildEmployeesTab() {
    final stats = _employeeStats ?? {};
    final totalEmployees = stats['totalEmployees'] as int? ?? 
      _employeesByPosition.fold<int>(0, (sum, item) => sum + (item['count'] as int));
    final activeEmployees = stats['activeEmployees'] as int? ?? 
      (totalEmployees * 0.85).round();
    final totalPayroll = stats['totalPayroll'] as double? ?? 180000.0;
    final avgSalary = stats['averageSalary'] as double? ?? 
      (totalPayroll / (totalEmployees > 0 ? totalEmployees : 1));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total',
                '$totalEmployees',
                Icons.people,
                Colors.blue,
              ).animate().fadeIn(duration: 400.ms).slideX(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Activos',
                '$activeEmployees',
                Icons.check_circle,
                Colors.green,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Nómina Total',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalPayroll),
                Icons.account_balance_wallet,
                Colors.orange,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Salario Prom.',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(avgSalary),
                Icons.payments,
                Colors.purple,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Pie chart - Employees by position
        _buildChartCard(
          'Empleados por Posición',
          _buildEmployeesPieChart(),
          height: 350,
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scale(),
        
        const SizedBox(height: 24),
        
        // Horizontal bar chart - Top employees
        _buildChartCard(
          'Top 5 Empleados por Ventas',
          _buildTopEmployeesChart(),
          height: 350,
        ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scale(),
      ],
    );
  }

  Widget _buildGeneralTab() {
    final totalSales = _salesByDay.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );
    final totalProfit = totalSales * 0.25;
    final growthRate = 12.5;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Ventas Totales',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalSales),
                Icons.attach_money,
                Colors.green,
              ).animate().fadeIn(duration: 400.ms).slideX(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Ganancias',
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalProfit),
                Icons.trending_up,
                Colors.blue,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        _buildGrowthCard(growthRate)
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideX(),
        
        const SizedBox(height: 24),
        
        // Combined chart - Sales and Profit
        _buildChartCard(
          'Ventas y Ganancias',
          _buildCombinedChart(),
          height: 350,
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale(),
        
        const SizedBox(height: 24),
        
        // Summary indicators
        _buildSummaryIndicators()
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .slideY(),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_upward, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, {double height = 300}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: height, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _salesByDay.length) {
                  final date = _salesByDay[value.toInt()]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              _salesByDay.length,
              (index) => FlSpot(
                index.toDouble(),
                _salesByDay[index]['amount'] as double,
              ),
            ),
            isCurved: true,
            color: accentColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: accentColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: accentColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesByCategoryChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelRotation: -45,
        labelStyle: TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: _salesByCategory,
          xValueMapper: (data, _) => data['category'] as String,
          yValueMapper: (data, _) => data['amount'] as double,
          pointColorMapper: (data, _) => data['color'] as Color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildTopProductsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Vendidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _topProducts.length,
              (index) {
                final product = _topProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(index),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${product['quantity']} unidades',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                            .format(product['revenue']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeesPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(
          _employeesByPosition.length,
          (index) {
            final item = _employeesByPosition[index];
            final total = _employeesByPosition.fold<int>(
              0,
              (sum, item) => sum + (item['count'] as int),
            );
            final percentage = ((item['count'] as int) / total * 100);
            
            return PieChartSectionData(
              color: item['color'] as Color,
              value: (item['count'] as int).toDouble(),
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopEmployeesChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        BarSeries<Map<String, dynamic>, String>(
          dataSource: _topEmployees,
          xValueMapper: (data, _) => data['name'] as String,
          yValueMapper: (data, _) => data['amount'] as double,
          color: primaryColor,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildCombinedChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: const Legend(isVisible: true),
      series: <CartesianSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          name: 'Ventas',
          dataSource: _salesByDay,
          xValueMapper: (data, _) => DateFormat('dd/MM').format(data['date'] as DateTime),
          yValueMapper: (data, _) => data['amount'] as double,
          color: Colors.blue,
        ),
        LineSeries<Map<String, dynamic>, String>(
          name: 'Ganancias',
          dataSource: _salesByDay,
          xValueMapper: (data, _) => DateFormat('dd/MM').format(data['date'] as DateTime),
          yValueMapper: (data, _) => (data['amount'] as double) * 0.25,
          color: Colors.green,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildGrowthCard(double growthRate) {
    final isPositive = growthRate >= 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isPositive
                ? [Colors.green.withOpacity(0.1), Colors.white]
                : [Colors.red.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 32,
              ).animate(onPlay: (controller) => controller.repeat())
                  .moveY(begin: 0, end: -5, duration: 800.ms)
                  .then()
                  .moveY(begin: -5, end: 0, duration: 800.ms),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crecimiento',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPositive ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryIndicators() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indicadores del Período',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildIndicatorRow('Margen de Ganancia', '25%', Colors.green, true),
            const Divider(height: 24),
            _buildIndicatorRow('Tasa de Conversión', '68%', Colors.blue, true),
            const Divider(height: 24),
            _buildIndicatorRow('Ticket Promedio', '\$2,850', Colors.orange, true),
            const Divider(height: 24),
            _buildIndicatorRow('Rotación de Inventario', '4.2x', Colors.purple, true),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String label, String value, Color color, bool isPositive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: color,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadData();
    }
  }
}
