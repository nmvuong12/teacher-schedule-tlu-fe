import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controller/app_controller.dart';
import '../../../data/model/models.dart';
import '../../widget/session_form.dart';

class SessionManagement extends StatefulWidget {
  const SessionManagement({super.key});

  @override
  State<SessionManagement> createState() => _SessionManagementState();
}

class _SessionManagementState extends State<SessionManagement> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _selectedFilter = 'all'; // 'all', 'today', 'upcoming', 'past', 'specific'
  DateTime? _selectedDate; // ✅ Ngày cụ thể để lọc
  String _statusFilter = 'all'; // 'all', 'Đã hủy', 'Chưa bắt đầu', 'Đang diễn ra', 'Đã hoàn thành'

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, child) {
        return Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Quản lý buổi học',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Spacer(),
                  // Quick filter buttons
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'today';
                            _currentPage = 0;
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.calendarDay, size: 14),
                        label: const Text('Hôm nay'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _selectedFilter == 'today' ? Colors.white : const Color(0xFF1E3A8A),
                          backgroundColor: _selectedFilter == 'today' ? const Color(0xFF1E3A8A) : Colors.transparent,
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'upcoming';
                            _currentPage = 0;
                          });
                        },
                        icon: const FaIcon(FontAwesomeIcons.calendarPlus, size: 14),
                        label: const Text('Sắp tới'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _selectedFilter == 'upcoming' ? Colors.white : const Color(0xFF1E3A8A),
                          backgroundColor: _selectedFilter == 'upcoming' ? const Color(0xFF1E3A8A) : Colors.transparent,
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ✅ Nút chọn ngày cụ thể
                      OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _selectedFilter = 'specific';
                              _currentPage = 0;
                            });
                          }
                        },
                        icon: const FaIcon(FontAwesomeIcons.calendar, size: 14),
                        label: Text(_selectedFilter == 'specific' && _selectedDate != null
                            ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                            : 'Chọn ngày'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _selectedFilter == 'specific' ? Colors.white : const Color(0xFF1E3A8A),
                          backgroundColor: _selectedFilter == 'specific' ? const Color(0xFF1E3A8A) : Colors.transparent,
                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddSessionDialog(context),
                        icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                        label: const Text('Thêm buổi học'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search and Filter
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên học phần, nội dung, phòng học...',
                        prefixIcon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        labelText: 'Lọc theo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                        DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
                        DropdownMenuItem(value: 'upcoming', child: Text('Sắp tới')),
                        DropdownMenuItem(value: 'past', child: Text('Đã qua')),
                        DropdownMenuItem(value: 'specific', child: Text('Ngày cụ thể')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                          _currentPage = 0; // Reset to first page when filter changes
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                        DropdownMenuItem(value: 'Chưa bắt đầu', child: Text('Chưa bắt đầu')),
                        DropdownMenuItem(value: 'Đang diễn ra', child: Text('Đang diễn ra')),
                        DropdownMenuItem(value: 'Đã hoàn thành', child: Text('Đã hoàn thành')),
                        DropdownMenuItem(value: 'Đã hủy', child: Text('Đã hủy')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                          _currentPage = 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter info
              if (_selectedFilter != 'all')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.filter, size: 14, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 8),
                      Text(
                        _getFilterDescription(),
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'all';
                            _currentPage = 0;
                          });
                        },
                        child: const Text('Xóa bộ lọc', style: TextStyle(color: Color(0xFF1E3A8A))),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Sessions table
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Builder(builder: (context) {
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);

                            final all = controller.sessions.where((session) {
                              // Text search filter
                              if (_searchController.text.isNotEmpty) {
                                final query = _searchController.text.toLowerCase();
                                final sectionName = session.className ?? session.subjectName ?? '';
                                if (!(session.content ?? '').toLowerCase().contains(query) &&
                                    !session.classroom.toLowerCase().contains(query) &&
                                    !(session.label ?? '').toLowerCase().contains(query) &&
                                    !sectionName.toLowerCase().contains(query)) {
                                  return false;
                                }
                              }

                              // Date filter
                              final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
                              switch (_selectedFilter) {
                                case 'today':
                                  return sessionDate.isAtSameMomentAs(today);
                                case 'upcoming':
                                  return sessionDate.isAfter(today);
                                case 'past':
                                  return sessionDate.isBefore(today);
                                case 'specific':
                                  // ✅ Lọc theo ngày cụ thể
                                  if (_selectedDate != null) {
                                    final specificDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
                                    return sessionDate.isAtSameMomentAs(specificDate);
                                  }
                                  return true;
                                case 'all':
                                default:
                                  return true;
                              }
                              // Status filter
                              // Only reached if date-filter above returned true
                            }).where((session) {
                              if (_statusFilter == 'all') return true;
                              return session.status == _statusFilter;
                            }).toList();
                            final total = all.length;
                            final pageCount = (total / _rowsPerPage).ceil();
                            if (_currentPage >= pageCount) {
                              _currentPage = 0;
                            }
                            int startIndex = _currentPage * _rowsPerPage;
                            if (startIndex < 0) startIndex = 0;
                            if (startIndex > total) startIndex = total;
                            final rawEnd = startIndex + _rowsPerPage;
                            final endIndex = rawEnd > total ? total : rawEnd;
                            final pageItems = all.sublist(startIndex, endIndex);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: DataTable2(
                                    columnSpacing: 12,
                                    horizontalMargin: 12,
                                    minWidth: 1200,
                                    columns: const [
                                      DataColumn2(
                                        label: Text('STT'),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('Học phần'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Ngày'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Phòng học'),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('Nội dung'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Thời gian'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Trạng thái'),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('Thao tác'),
                                        size: ColumnSize.S,
                                      ),
                                    ],
                                    rows: pageItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final session = entry.value;
                                      final sectionName = session.className ?? session.subjectName ?? '';
                                      final stt = startIndex + index + 1;

                                      // Format date as dd/MM/yyyy
                                      final dateStr = '${session.date.day.toString().padLeft(2, '0')}/${session.date.month.toString().padLeft(2, '0')}/${session.date.year}';

                                      return DataRow2(
                                        cells: [
                                          DataCell(Text(stt.toString())),
                                          DataCell(
                                            Text(
                                              sectionName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1E3A8A),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(dateStr)),
                                          DataCell(Text(session.classroom)),
                                          DataCell(Text(session.content ?? '')),
                                          DataCell(Text(session.timeRange)),
                                          DataCell(_buildStatusChip(session.status)),
                                          DataCell(
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                                                    onPressed: () => _showEditSessionDialog(context, session),
                                                  ),
                                                  IconButton(
                                                    icon: const FaIcon(FontAwesomeIcons.trash, size: 14, color: Colors.red),
                                                    onPressed: () => _showDeleteConfirmDialog(context, session),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildPaginationBar(total),
                              ],
                            );
                          }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Đã hoàn thành':
        color = Colors.green;
        break;
      case 'Đang diễn ra':
        color = Colors.blue;
        break;
      case 'Chưa bắt đầu':
        color = Colors.orange;
        break;
      case 'Đã hủy':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPaginationBar(int total) {
    final totalPages = (total / _rowsPerPage).ceil();
    final showingStart = total == 0 ? 0 : _currentPage * _rowsPerPage + 1;
    final showingEnd = ((
      (_currentPage + 1) * _rowsPerPage
    ) > total ? total : ((_currentPage + 1) * _rowsPerPage));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hiển thị $showingStart đến $showingEnd của $total kết quả',
          style: const TextStyle(color: Colors.grey),
        ),
        Row(
          children: [
            const Text('Số bản ghi/trang: '),
            DropdownButton<int>(
              value: _rowsPerPage,
              items: const [10, 20, 50]
                  .map((n) => DropdownMenuItem<int>(value: n, child: Text('$n')))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _rowsPerPage = value;
                  _currentPage = 0;
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
            ),
            Text('${totalPages == 0 ? 0 : _currentPage + 1}/$totalPages'),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
              onPressed: (_currentPage + 1) < totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  void _showAddSessionDialog(BuildContext context) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => SessionForm(
        onSubmit: (session) async {
          bool ok = false;
          String errorMessage = 'Thêm buổi học thất bại';
          try {
            ok = await outerContext.read<AppController>().createSession(session);
          } catch (e) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          }
          if (ok) {
            Navigator.of(dialogCtx).pop();
            _showSnack(outerContext, 'Thêm buổi học thành công', true);
          } else {
            _showSnack(outerContext, errorMessage, false);
          }
        },
      ),
    );
  }

  void _showEditSessionDialog(BuildContext context, Session session) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => SessionForm(
        session: session,
        onSubmit: (updatedSession) async {
          bool ok = false;
          String errorMessage = 'Cập nhật buổi học thất bại';
          try {
            ok = await outerContext.read<AppController>().updateSession(updatedSession);
          } catch (e) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          }
          if (ok) {
            Navigator.of(dialogCtx).pop();
            _showSnack(outerContext, 'Cập nhật buổi học thành công', true);
          } else {
            _showSnack(outerContext, errorMessage, false);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Session session) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa buổi học "${session.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool ok = false;
              String errorMessage = 'Xóa buổi học thất bại';
              try {
                if (session.sessionId != null) {
                  ok = await outerContext.read<AppController>().deleteSession(session.sessionId!);
                }
              } catch (e) {
                errorMessage = e.toString().replaceFirst('Exception: ', '');
              }
              if (Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
              _showSnack(outerContext, ok ? 'Xóa buổi học thành công' : errorMessage, ok);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, bool success) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    });
  }

  String _getFilterDescription() {
    switch (_selectedFilter) {
      case 'today':
        return 'Hiển thị buổi học hôm nay';
      case 'upcoming':
        return 'Hiển thị buổi học sắp tới';
      case 'past':
        return 'Hiển thị buổi học đã qua';
      case 'specific':
        if (_selectedDate != null) {
          return 'Hiển thị buổi học ngày ${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';
        }
        return 'Chưa chọn ngày cụ thể';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}