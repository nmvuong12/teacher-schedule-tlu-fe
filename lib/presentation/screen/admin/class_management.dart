import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../controller/app_controller.dart';
import '../../../data/model/models.dart';
import '../../widget/class_form.dart';

class ClassManagement extends StatefulWidget {
  const ClassManagement({super.key});

  @override
  State<ClassManagement> createState() => _ClassManagementState();
}

class _ClassManagementState extends State<ClassManagement> {
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 10;
  int _currentPage = 0;

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
                    'Quản lý lớp học',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddClassDialog(context),
                    icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
                    label: const Text('Thêm lớp học'),
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
              const SizedBox(height: 24),
              
              // Search
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm lớp học...',
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
                ],
              ),
              const SizedBox(height: 24),
              
              // Classes table
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
                            final all = controller.classes.where((clazz) {
                              if (_searchController.text.isEmpty) return true;
                              final query = _searchController.text.toLowerCase();
                              return clazz.className.toLowerCase().contains(query);
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
                                    minWidth: 600,
                                    columns: const [
                                      DataColumn2(
                                        label: Text('ID'),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('Tên lớp'),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('Thao tác'),
                                        size: ColumnSize.S,
                                      ),
                                    ],
                                    rows: pageItems.map((clazz) {
                                      return DataRow2(
                                        cells: [
                                          DataCell(Text(clazz.classId?.toString() ?? 'N/A')),
                                          DataCell(Text(clazz.className)),
                                          DataCell(
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                                                    onPressed: () => _showEditClassDialog(context, clazz),
                                                  ),
                                                  IconButton(
                                                    icon: const FaIcon(FontAwesomeIcons.trash, size: 14, color: Colors.red),
                                                    onPressed: () => _showDeleteConfirmDialog(context, clazz),
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

  void _showAddClassDialog(BuildContext context) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => ClassForm(
        onSubmit: (clazz) async {
          // Hiển thị loading dialog
          showDialog(
            context: dialogCtx,
            barrierDismissible: false,
            builder: (loadingCtx) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tạo lớp học...'),
                    ],
                  ),
                ),
              ),
            ),
          );

          bool ok = false;
          String errorMessage = 'Thêm lớp học thất bại';
          try {
            ok = await outerContext.read<AppController>().createClass(clazz);
          } catch (e) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          } finally {
            // Đóng loading dialog
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop(); // Đóng loading dialog
            }
          }

          if (ok) {
            // Đóng form dialog
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop();
            }
            _showSnack(outerContext, 'Thêm lớp học thành công', true);
          } else {
            _showSnack(outerContext, errorMessage, false);
          }
        },
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, SchoolClass clazz) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => ClassForm(
        clazz: clazz,
        onSubmit: (updatedClass) async {
          // Hiển thị loading dialog
          showDialog(
            context: dialogCtx,
            barrierDismissible: false,
            builder: (loadingCtx) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang cập nhật lớp học...'),
                    ],
                  ),
                ),
              ),
            ),
          );

          bool ok = false;
          String errorMessage = 'Cập nhật lớp học thất bại';
          try {
            ok = await outerContext.read<AppController>().updateClass(updatedClass);
          } catch (e) {
            errorMessage = e.toString().replaceFirst('Exception: ', '');
          } finally {
            // Đóng loading dialog
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop(); // Đóng loading dialog
            }
          }

          if (ok) {
            // Đóng form dialog
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop();
            }
            _showSnack(outerContext, 'Cập nhật lớp học thành công', true);
          } else {
            _showSnack(outerContext, errorMessage, false);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SchoolClass clazz) {
    final outerContext = context;
    showDialog(
      context: outerContext,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${clazz.className}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Hiển thị loading dialog
              showDialog(
                context: dialogCtx,
                barrierDismissible: false,
                builder: (loadingCtx) => const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Đang xóa lớp học...'),
                        ],
                      ),
                    ),
                  ),
                ),
              );

              bool ok = false;
              String errorMessage = 'Xóa lớp học thất bại';
              try {
                if (clazz.classId != null) {
                  ok = await outerContext.read<AppController>().deleteClass(clazz.classId!);
                }
              } catch (e) {
                errorMessage = e.toString().replaceFirst('Exception: ', '');
              } finally {
                // Đóng loading dialog
                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop(); // Đóng loading dialog
                }
              }

              // Đóng confirm dialog
              if (Navigator.of(dialogCtx).canPop()) {
                Navigator.of(dialogCtx).pop();
              }
              _showSnack(outerContext, ok ? 'Xóa lớp học thành công' : errorMessage, ok);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
