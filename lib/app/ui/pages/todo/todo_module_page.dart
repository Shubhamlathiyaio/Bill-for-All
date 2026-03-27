import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/todo_controller.dart';
import '../../../data/models/todo_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/helpers/injectable/injectable.dart';
import '../../../utils/themes/app_colors.dart';
import '../../../utils/themes/app_styles.dart';
import '../profile/profile_page.dart';

// ── Entry point ──────────────────────────────────────────────────────────────

/// The top-level page registered for the "todo" module tab.
/// It hosts its own inner bottom nav:  Dashboard · Modules · Profile
class TodoModulePage extends StatefulWidget {
  const TodoModulePage({super.key});

  @override
  State<TodoModulePage> createState() => _TodoModulePageState();
}

class _TodoModulePageState extends State<TodoModulePage> {
  int _index = 0;

  static const _pages = <Widget>[
    _DashboardTab(),
    _SubModulesTab(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: colors.bg1,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colors.bg0,
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: _InnerBottomNav(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          colors: colors,
        ),
      ),
    );
  }
}

// ── Inner bottom nav ─────────────────────────────────────────────────────────

class _InnerBottomNav extends StatelessWidget {
  const _InnerBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.colors,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bg1,
        border: Border(
          top: BorderSide(color: colors.textPrimary.changeOpacity(0.08)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textPrimary.changeOpacity(0.35),
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w400),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Modules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Tab 0: Dashboard ─────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    final ctrl = getIt<TodoController>();

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.bg1,
          onRefresh: ctrl.fetchTodos,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [
                              HexColor.fromHex('#6C63FF'),
                              HexColor.fromHex('#9B59B6'),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('To-Do', style: styles.s24w700White),
                          Obx(() {
                            final total = ctrl.todos.length;
                            return Text(
                              '$total task${total == 1 ? '' : 's'} total',
                              style: styles.s13w400Muted,
                            );
                          }),
                        ],
                      ),
                      const Spacer(),
                      Obx(() => ctrl.isLoading.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : IconButton(
                              onPressed: ctrl.fetchTodos,
                              icon: Icon(
                                Icons.refresh_rounded,
                                color: colors.textPrimary.changeOpacity(0.5),
                                size: 22,
                              ),
                            )),
                    ],
                  ),
                ),
              ),

              // ── Stats + progress ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  final total = ctrl.todos.length;
                  final pending =
                      ctrl.todos.where((t) => t.status == 'pending').length;
                  final inProgress =
                      ctrl.todos.where((t) => t.status == 'in-progress').length;
                  final done =
                      ctrl.todos.where((t) => t.status == 'completed').length;
                  final pct = total == 0 ? 0.0 : done / total;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats row
                        Row(
                          children: [
                            _StatCard(
                              label: 'Total',
                              value: '$total',
                              color: colors.primary,
                              styles: styles,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Pending',
                              value: '$pending',
                              color: colors.warning,
                              styles: styles,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Active',
                              value: '$inProgress',
                              color: const Color(0xFF3B82F6),
                              styles: styles,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Done',
                              value: '$done',
                              color: colors.success,
                              styles: styles,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Progress bar card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.bg1,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colors.textPrimary.changeOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Overall progress',
                                      style: styles.s14w500White),
                                  Text(
                                    '${(pct * 100).round()}%',
                                    style: styles.s14w500White
                                        .copyWith(color: colors.primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 8,
                                  backgroundColor:
                                      colors.textPrimary.changeOpacity(0.08),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      colors.primary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$done of $total tasks completed',
                                style: styles.s13w400Muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // ── Recent tasks header ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Tasks', style: styles.s16w600White),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.todoAddEdit),
                        child: Text('+ Add', style: styles.s13w600Primary),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Task list ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: Obx(() {
                  if (ctrl.isLoading.value && ctrl.todos.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                              color: colors.primary),
                        ),
                      ),
                    );
                  }

                  final recent = ctrl.todos.take(8).toList();

                  if (recent.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyState(colors: colors, styles: styles),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        if (i == recent.length) {
                          return const SizedBox(height: 24);
                        }
                        return _TodoRow(
                          todo: recent[i],
                          colors: colors,
                          styles: styles,
                          onToggle: () => ctrl.toggleStatus(recent[i]),
                        );
                      },
                      childCount: recent.length + 1,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => Get.toNamed(AppRoutes.todoAddEdit),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

// ── Tab 1: Sub-modules grid ──────────────────────────────────────────────────

class _SubModulesTab extends StatelessWidget {
  const _SubModulesTab();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    final ctrl = getIt<TodoController>();

    return Scaffold(
      backgroundColor: colors.bg0,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Modules', style: styles.s28w700White),
                    const SizedBox(height: 4),
                    Text('Tap a module to open it',
                        style: styles.s13w400Muted),
                  ],
                ),
              ),
            ),

            // Cards grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: Obx(() {
                final totalTasks = ctrl.todos.length;
                final pendingTasks =
                    ctrl.todos.where((t) => t.status != 'completed').length;
                final labelCount = ctrl.categories.length;

                final subModules = [
                  _SubModuleData(
                    label: 'Tasks',
                    description: 'Manage your daily tasks',
                    icon: Icons.check_circle_outline_rounded,
                    badgeLabel: '$pendingTasks pending',
                    gradientStart: '#6C63FF',
                    gradientEnd: '#9B59B6',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => const _FullTasksPage())),
                  ),
                  _SubModuleData(
                    label: 'Labels',
                    description: 'Organise tasks by label',
                    icon: Icons.label_outline_rounded,
                    badgeLabel:
                        '$labelCount label${labelCount == 1 ? '' : 's'}',
                    gradientStart: '#11998E',
                    gradientEnd: '#38EF7D',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => const _FullLabelsPage())),
                  ),
                ];

                return SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.92,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _SubModuleCard(
                      data: subModules[i],
                      colors: colors,
                      styles: styles,
                    ),
                    childCount: subModules.length,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-module card data ─────────────────────────────────────────────────────

class _SubModuleData {
  const _SubModuleData({
    required this.label,
    required this.description,
    required this.icon,
    required this.badgeLabel,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final String badgeLabel;
  final String gradientStart;
  final String gradientEnd;
  final VoidCallback onTap;
}

// ── Sub-module card widget ───────────────────────────────────────────────────

class _SubModuleCard extends StatelessWidget {
  const _SubModuleCard({
    required this.data,
    required this.colors,
    required this.styles,
  });

  final _SubModuleData data;
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    final gStart = HexColor.fromHex(data.gradientStart);
    final gEnd = HexColor.fromHex(data.gradientEnd);

    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.bg1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.textPrimary.changeOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [gStart, gEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(data.icon, color: Colors.white, size: 22),
            ),

            const Spacer(),

            // Label + description
            Text(data.label,
                style: styles.s14w700White.copyWith(fontSize: 15)),
            const SizedBox(height: 3),
            Text(
              data.description,
              style: styles.s11w400Muted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Badge + arrow
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: gStart.changeOpacity(0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.badgeLabel,
                    style: styles.s11w400Muted.copyWith(
                      color: gStart.changeOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: colors.textPrimary.changeOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full Tasks page (pushed) ─────────────────────────────────────────────────

class _FullTasksPage extends StatelessWidget {
  const _FullTasksPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    final ctrl = getIt<TodoController>();

    return Scaffold(
      backgroundColor: colors.bg0,
      appBar: AppBar(
        title:
            Text('Tasks', style: styles.s14w500White.copyWith(fontSize: 18)),
        backgroundColor: colors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: colors.textPrimary.changeOpacity(0.8)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: colors.textPrimary.changeOpacity(0.8)),
            onPressed: ctrl.fetchTodos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() => Row(
                  children:
                      ['All', 'Pending', 'In-Progress', 'Completed'].map((f) {
                    final sel = ctrl.currentFilter.value.toLowerCase() ==
                        f.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f,
                            style: sel
                                ? styles.s13w600Primary
                                : styles.s13w400Muted),
                        selected: sel,
                        onSelected: (_) => ctrl.setFilter(f),
                        backgroundColor: colors.bg1,
                        selectedColor: colors.primary.changeOpacity(0.15),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: sel
                                ? colors.primary
                                : colors.textPrimary.changeOpacity(0.1),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ),

          // Task list
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value && ctrl.todos.isEmpty) {
                return Center(
                    child:
                        CircularProgressIndicator(color: colors.primary));
              }

              final list = ctrl.filteredTodos;

              if (list.isEmpty) {
                return _EmptyState(colors: colors, styles: styles);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final todo = list[i];
                  final cat = ctrl.categories
                          .firstWhereOrNull((c) => c.id == todo.categoryId)
                          ?.name ??
                      'General';
                  return _TodoCard(
                    todo: todo,
                    cat: cat,
                    colors: colors,
                    styles: styles,
                    onToggle: () => ctrl.toggleStatus(todo),
                    onDelete: () => ctrl.deleteTodo(todo.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => Get.toNamed(AppRoutes.todoAddEdit),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

// ── Full Labels page (pushed) ────────────────────────────────────────────────

class _FullLabelsPage extends StatelessWidget {
  const _FullLabelsPage();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;
    final ctrl = getIt<TodoController>();

    return Scaffold(
      backgroundColor: colors.bg0,
      appBar: AppBar(
        title:
            Text('Labels', style: styles.s14w500White.copyWith(fontSize: 18)),
        backgroundColor: colors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: colors.textPrimary.changeOpacity(0.8)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        final cats = ctrl.categories;
        if (cats.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.label_outline_rounded,
                    size: 56,
                    color: colors.textPrimary.changeOpacity(0.15)),
                const SizedBox(height: 16),
                Text('No labels yet.', style: styles.s14w400Muted),
                const SizedBox(height: 8),
                Text(
                  'Labels help you organise tasks.',
                  style: styles.s13w400Muted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final cat = cats[i];
            final count =
                ctrl.todos.where((t) => t.categoryId == cat.id).length;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: colors.bg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colors.textPrimary.changeOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.changeOpacity(0.12),
                    ),
                    child: Icon(Icons.label_rounded,
                        color: colors.primary, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text(cat.name, style: styles.s14w500White)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.changeOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count task${count == 1 ? '' : 's'}',
                      style: styles.s13w600Primary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () => Get.snackbar(
          'Coming Soon',
          'Add label feature coming soon.',
          snackPosition: SnackPosition.BOTTOM,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.styles,
  });

  final String label;
  final String value;
  final Color color;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.changeOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.changeOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    styles.s24w700White.copyWith(color: color, fontSize: 20)),
            const SizedBox(height: 3),
            Text(label, style: styles.s11w400Muted),
          ],
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    required this.todo,
    required this.colors,
    required this.styles,
    required this.onToggle,
  });

  final TodoModel todo;
  final AppColors colors;
  final AppStyles styles;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.textPrimary.changeOpacity(0.05)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              todo.status == 'completed'
                  ? Icons.check_circle_rounded
                  : todo.status == 'in-progress'
                      ? Icons.play_circle_fill_rounded
                      : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: todo.status == 'completed'
                  ? colors.success
                  : todo.status == 'in-progress'
                      ? colors.warning
                      : colors.textPrimary.changeOpacity(0.3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              todo.title,
              style: styles.s14w400White.copyWith(
                fontSize: 13,
                decoration: todo.status == 'completed'
                    ? TextDecoration.lineThrough
                    : null,
                color: todo.status == 'completed'
                    ? colors.textPrimary.changeOpacity(0.4)
                    : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (todo.dueDate != null) ...[
            const SizedBox(width: 8),
            Text('${todo.dueDate!.day}/${todo.dueDate!.month}',
                style: styles.s11w400Muted),
          ],
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.cat,
    required this.colors,
    required this.styles,
    required this.onToggle,
    required this.onDelete,
  });

  final TodoModel todo;
  final String cat;
  final AppColors colors;
  final AppStyles styles;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.textPrimary.changeOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              todo.status == 'completed'
                  ? Icons.check_circle_rounded
                  : todo.status == 'in-progress'
                      ? Icons.play_circle_fill_rounded
                      : Icons.radio_button_unchecked_rounded,
              color: todo.status == 'completed'
                  ? colors.success
                  : todo.status == 'in-progress'
                      ? colors.warning
                      : colors.textPrimary.changeOpacity(0.3),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: styles.s14w500White.copyWith(
                    decoration: todo.status == 'completed'
                        ? TextDecoration.lineThrough
                        : null,
                    color: todo.status == 'completed'
                        ? colors.textPrimary.changeOpacity(0.5)
                        : colors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                if (todo.description != null &&
                    todo.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(todo.description!, style: styles.s13w400Muted),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.textPrimary.changeOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(cat,
                          style: styles.s11w400Muted
                              .copyWith(fontWeight: FontWeight.w500)),
                    ),
                    const Spacer(),
                    if (todo.dueDate != null) ...[
                      Icon(Icons.calendar_today_rounded,
                          size: 12,
                          color: colors.textPrimary.changeOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        '${todo.dueDate!.day}/${todo.dueDate!.month}',
                        style: styles.s11w400Muted,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  size: 20, color: colors.error.changeOpacity(0.7)),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.styles});
  final AppColors colors;
  final AppStyles styles;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 56, color: colors.textPrimary.changeOpacity(0.15)),
          const SizedBox(height: 16),
          Text('No tasks found.', style: styles.s14w400Muted),
        ],
      ),
    );
  }
}
