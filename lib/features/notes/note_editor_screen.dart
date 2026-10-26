import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/note_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_responsive_container.dart';

class NoteEditorScreen extends StatefulWidget {
  final String noteId;

  const NoteEditorScreen({super.key, required this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  final FocusNode _bodyFocusNode = FocusNode();

  Note? _currentNote;
  Timer? _debounceTimer;
  bool _isNewAndUntouched = false;

  // Undo/Redo history stack
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  bool _isUndoOrRedoOperation = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();

    _loadNote();
  }

  void _loadNote() {
    final state = context.read<HavenState>();
    final match = state.notes.where((n) => n.id == widget.noteId);
    if (match.isNotEmpty) {
      _currentNote = match.first;
      _titleController.text = _currentNote!.title;
      _bodyController.text = _currentNote!.body;
      _isNewAndUntouched =
          _currentNote!.title.isEmpty && _currentNote!.body.isEmpty;
      _undoStack.add(_currentNote!.body);
    }

    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onBodyChanged);
  }

  void _onBodyChanged() {
    if (!_isUndoOrRedoOperation) {
      if (_undoStack.isEmpty || _undoStack.last != _bodyController.text) {
        _undoStack.add(_bodyController.text);
        _redoStack.clear();
      }
    }
    _onTextChanged();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), _saveQuietly);
  }

  Future<void> _saveQuietly() async {
    if (_currentNote == null) return;
    final title = _titleController.text;
    final body = _bodyController.text;

    // Check if changed
    if (title == _currentNote!.title && body == _currentNote!.body) return;

    _currentNote = _currentNote!.copyWith(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
    );

    _isNewAndUntouched = false;
    await context.read<HavenState>().saveNote(_currentNote!);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _flushSave();
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _flushSave() async {
    if (_currentNote == null) return;
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    // If completely empty and was never edited, clean up
    if (_isNewAndUntouched && title.isEmpty && body.isEmpty) {
      await context.read<HavenState>().deleteNote(_currentNote!.id);
      return;
    }

    if (title != _currentNote!.title || body != _currentNote!.body) {
      _currentNote = _currentNote!.copyWith(title: title, body: body);
      await context.read<HavenState>().saveNote(_currentNote!);
    }
  }

  void _undo() {
    if (_undoStack.length > 1) {
      _isUndoOrRedoOperation = true;
      final current = _undoStack.removeLast();
      _redoStack.add(current);
      final previous = _undoStack.last;
      _bodyController.text = previous;
      _bodyController.selection = TextSelection.collapsed(
        offset: previous.length,
      );
      _isUndoOrRedoOperation = false;
      _onTextChanged();
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      _isUndoOrRedoOperation = true;
      final next = _redoStack.removeLast();
      _undoStack.add(next);
      _bodyController.text = next;
      _bodyController.selection = TextSelection.collapsed(offset: next.length);
      _isUndoOrRedoOperation = false;
      _onTextChanged();
    }
  }

  void _selectAll() {
    _bodyController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _bodyController.text.length,
    );
    _bodyFocusNode.requestFocus();
  }

  double _getFontSizeValue(String? size) {
    switch (size) {
      case 'sm':
        return 15.0;
      case 'lg':
        return 20.0;
      case 'md':
      default:
        return 17.0;
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _NoteOptionsSheet(
          note: _currentNote!,
          onColorSelected: (colorId) async {
            setState(() {
              _currentNote = _currentNote!.copyWith(colorId: colorId);
            });
            await context.read<HavenState>().saveNote(_currentNote!);
          },
          onFontSizeChanged: (fontSize) async {
            setState(() {
              _currentNote = _currentNote!.copyWith(fontSize: fontSize);
            });
            await context.read<HavenState>().saveNote(_currentNote!);
          },
          onSelectAll: () {
            Navigator.pop(sheetContext);
            _selectAll();
          },
          onUndo: () {
            Navigator.pop(sheetContext);
            _undo();
          },
          onRedo: () {
            Navigator.pop(sheetContext);
            _redo();
          },
          onDuplicate: () async {
            Navigator.pop(sheetContext);
            final copy = await context.read<HavenState>().duplicateNote(
              _currentNote!,
            );
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(noteId: copy.id),
                ),
              );
            }
          },
          onDelete: () async {
            Navigator.pop(sheetContext);
            _confirmDelete(context);
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? HavenColors.darkSurface
              : HavenColors.lightCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: isDark ? HavenColors.darkBorder : HavenColors.lightBorder,
            ),
          ),
          title: Text(
            'Delete note?',
            style: HavenTypography.headlineSm(
              isDark
                  ? HavenColors.darkTextPrimary
                  : HavenColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'This action is permanent and cannot be undone.',
            style: HavenTypography.bodySm(
              isDark
                  ? HavenColors.darkTextSecondary
                  : HavenColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: Text(
                'Cancel',
                style: HavenTypography.labelMd(
                  isDark
                      ? HavenColors.darkTextSecondary
                      : HavenColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dlgContext);
                await context.read<HavenState>().deleteNote(_currentNote!.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Delete',
                style: HavenTypography.labelMd(HavenColors.error)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = HavenColors.getColorById(
      _currentNote?.colorId,
      isAppDark: isDark,
    );

    final pageBg = _currentNote?.colorId != null
        ? palette.color
        : (isDark ? HavenColors.darkCanvas : HavenColors.lightCanvas);
    final textPrimary = _currentNote?.colorId != null
        ? palette.textColor
        : (isDark ? HavenColors.darkTextPrimary : HavenColors.lightTextPrimary);
    final textSecondary = _currentNote?.colorId != null
        ? palette.secondaryColor
        : (isDark
              ? HavenColors.darkTextSecondary
              : HavenColors.lightTextSecondary);

    final fontSize = _getFontSizeValue(_currentNote?.fontSize);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: HavenResponsiveContainer(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 24.0),
                      color: textPrimary,
                      onPressed: () {
                        _flushSave();
                        Navigator.pop(context);
                      },
                      tooltip: 'Back',
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 24.0),
                      color: textPrimary,
                      onPressed: () => _showOptionsMenu(context),
                      tooltip: 'More options',
                    ),
                  ],
                ),
              ),

              // Title and Note Body Editor
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  children: [
                    // Category & Date Indicator
                    Row(
                      children: [
                        Text(
                          _currentNote?.category.toUpperCase() ?? 'PERSONAL',
                          style: HavenTypography.caption(textSecondary)
                              .copyWith(
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),

                    // Title Field
                    TextField(
                      controller: _titleController,
                      style: HavenTypography.headlineMd(textPrimary)
                          .copyWith(fontWeight: FontWeight.w600, height: 1.3),
                      cursorColor: textPrimary,
                      decoration: InputDecoration(
                        hintText: 'Note title',
                        hintStyle: HavenTypography.headlineMd(textSecondary)
                            .copyWith(fontWeight: FontWeight.w500),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Multiline Body Field
                    TextField(
                      controller: _bodyController,
                      focusNode: _bodyFocusNode,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontFamily: HavenTypography.fontFamily,
                        fontSize: fontSize,
                        height: 1.65,
                        color: textPrimary,
                      ),
                      cursorColor: textPrimary,
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        hintStyle: TextStyle(
                          fontFamily: HavenTypography.fontFamily,
                          fontSize: fontSize,
                          height: 1.65,
                          color: textSecondary,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 120.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteOptionsSheet extends StatefulWidget {
  final Note note;
  final ValueChanged<String?> onColorSelected;
  final ValueChanged<String> onFontSizeChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _NoteOptionsSheet({
    required this.note,
    required this.onColorSelected,
    required this.onFontSizeChanged,
    required this.onSelectAll,
    required this.onUndo,
    required this.onRedo,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  State<_NoteOptionsSheet> createState() => _NoteOptionsSheetState();
}

class _NoteOptionsSheetState extends State<_NoteOptionsSheet> {
  bool _showColorPicker = false;
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.note.fontSize ?? 'md';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF141414) : Colors.white;
    final itemBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF6F6F6);
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE8E8E8);
    final textPrimary = isDark ? Colors.white : const Color(0xFF171717);
    final textSecondary = isDark
        ? const Color(0xFFA3A3A3)
        : const Color(0xFF707070);

    return Container(
      constraints: const BoxConstraints(maxWidth: 440.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(999.0),
              ),
            ),
          ),

          if (_showColorPicker) ...[
            // Color picker subview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _showColorPicker = false),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18.0),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: textPrimary,
                    padding: EdgeInsets.zero,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onColorSelected(null);
                    setState(() => _showColorPicker = false);
                  },
                  child: Text(
                    'Restore default',
                    style: HavenTypography.labelSm(textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.85,
              ),
              itemCount: HavenColors.writingPalette.length,
              itemBuilder: (context, index) {
                final item = HavenColors.writingPalette[index];
                final isSelected = widget.note.colorId == item.id;
                return GestureDetector(
                  onTap: () {
                    widget.onColorSelected(item.id);
                    setState(() => _showColorPicker = false);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isSelected ? textPrimary : borderColor,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28.0,
                          height: 28.0,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 1.0),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16.0,
                                  color: item.textColor,
                                )
                              : null,
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HavenTypography.caption(textSecondary)
                              .copyWith(fontSize: 10.0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12.0),
          ] else ...[
            // Main menu view
            Text(
              'APPEARANCE',
              style: HavenTypography.caption(textSecondary)
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                color: itemBg,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => setState(() => _showColorPicker = true),
                    leading: Icon(
                      Icons.palette_outlined,
                      size: 20.0,
                      color: textSecondary,
                    ),
                    title: Text(
                      'Background colour',
                      style: HavenTypography.bodyMd(textPrimary),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20.0,
                    ),
                  ),
                  Divider(height: 1.0, color: borderColor),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_size_rounded,
                              size: 20.0,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              'Text size',
                              style: HavenTypography.bodyMd(textPrimary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _SizeButton(
                              label: 'S',
                              isSelected: _selectedSize == 'sm',
                              onTap: () {
                                setState(() => _selectedSize = 'sm');
                                widget.onFontSizeChanged('sm');
                              },
                            ),
                            const SizedBox(width: 6.0),
                            _SizeButton(
                              label: 'M',
                              isSelected: _selectedSize == 'md',
                              onTap: () {
                                setState(() => _selectedSize = 'md');
                                widget.onFontSizeChanged('md');
                              },
                            ),
                            const SizedBox(width: 6.0),
                            _SizeButton(
                              label: 'L',
                              isSelected: _selectedSize == 'lg',
                              onTap: () {
                                setState(() => _selectedSize = 'lg');
                                widget.onFontSizeChanged('lg');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18.0),
            Text(
              'WRITING ACTIONS',
              style: HavenTypography.caption(textSecondary)
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                color: itemBg,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: widget.onSelectAll,
                    leading: Icon(
                      Icons.select_all_rounded,
                      size: 20.0,
                      color: textSecondary,
                    ),
                    title: Text(
                      'Select all text',
                      style: HavenTypography.bodyMd(textPrimary),
                    ),
                  ),
                  Divider(height: 1.0, color: borderColor),
                  ListTile(
                    onTap: widget.onUndo,
                    leading: Icon(
                      Icons.undo_rounded,
                      size: 20.0,
                      color: textSecondary,
                    ),
                    title: Text(
                      'Undo',
                      style: HavenTypography.bodyMd(textPrimary),
                    ),
                  ),
                  Divider(height: 1.0, color: borderColor),
                  ListTile(
                    onTap: widget.onRedo,
                    leading: Icon(
                      Icons.redo_rounded,
                      size: 20.0,
                      color: textSecondary,
                    ),
                    title: Text(
                      'Redo',
                      style: HavenTypography.bodyMd(textPrimary),
                    ),
                  ),
                  Divider(height: 1.0, color: borderColor),
                  ListTile(
                    onTap: widget.onDuplicate,
                    leading: Icon(
                      Icons.copy_rounded,
                      size: 20.0,
                      color: textSecondary,
                    ),
                    title: Text(
                      'Duplicate note',
                      style: HavenTypography.bodyMd(textPrimary),
                    ),
                  ),
                  Divider(height: 1.0, color: borderColor),
                  ListTile(
                    onTap: widget.onDelete,
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      size: 20.0,
                      color: HavenColors.error,
                    ),
                    title: Text(
                      'Delete note',
                      style: HavenTypography.bodyMd(HavenColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? Colors.white : const Color(0xFF171717);
    final activeText = isDark ? const Color(0xFF171717) : Colors.white;
    final inactiveText = isDark
        ? const Color(0xFFA3A3A3)
        : const Color(0xFF707070);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 32.0,
        height: 28.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            color: isSelected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}
