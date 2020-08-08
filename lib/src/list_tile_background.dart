// Copyright 2020 J-P Nurmi <jpnurmi@gmail.com>
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef RectCallback = Rect Function();
typedef _GetRectCallback = RectCallback Function(RenderBox referenceBox);
typedef _CheckContext = bool Function(BuildContext context);

class ListTileBackground extends StatelessWidget {
  const ListTileBackground({
    Key key,
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor = MouseCursor.defer,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.pressColor,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
  })  : assert(mouseCursor != null),
        assert(excludeFromSemantics != null),
        assert(autofocus != null),
        assert(canRequestFocus != null),
        super(key: key);

  final Widget child;
  final GestureTapCallback onTap;
  final GestureTapDownCallback onTapDown;
  final GestureTapCallback onTapCancel;
  final GestureTapCallback onDoubleTap;
  final GestureLongPressCallback onLongPress;
  final ValueChanged<bool> onHighlightChanged;
  final ValueChanged<bool> onHover;
  final MouseCursor mouseCursor;
  final BorderRadius borderRadius;
  final ShapeBorder customBorder;
  final Color focusColor;
  final Color hoverColor;
  final Color pressColor;
  final bool excludeFromSemantics;
  final ValueChanged<bool> onFocusChange;
  final bool autofocus;
  final FocusNode focusNode;
  final bool canRequestFocus;

  RectCallback getRectCallback(RenderBox referenceBox) => null;

  @override
  Widget build(BuildContext context) {
    return _ListTileBackgroundStateWidget(
      child: child,
      onTap: onTap,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHighlightChanged: onHighlightChanged,
      onHover: onHover,
      mouseCursor: mouseCursor,
      borderRadius: borderRadius,
      customBorder: customBorder,
      focusColor: focusColor,
      hoverColor: hoverColor,
      pressColor: pressColor,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      getRectCallback: getRectCallback,
      debugCheckContext: debugCheckContext,
    );
  }

  @mustCallSuper
  bool debugCheckContext(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    return true;
  }
}

class _ListTileBackgroundStateWidget extends StatefulWidget {
  const _ListTileBackgroundStateWidget({
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor = MouseCursor.defer,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.pressColor,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.getRectCallback,
    this.debugCheckContext,
  })  : assert(excludeFromSemantics != null),
        assert(autofocus != null),
        assert(canRequestFocus != null),
        assert(mouseCursor != null);

  final Widget child;
  final GestureTapCallback onTap;
  final GestureTapDownCallback onTapDown;
  final GestureTapCallback onTapCancel;
  final GestureTapCallback onDoubleTap;
  final GestureLongPressCallback onLongPress;
  final ValueChanged<bool> onHighlightChanged;
  final ValueChanged<bool> onHover;
  final MouseCursor mouseCursor;
  final BorderRadius borderRadius;
  final ShapeBorder customBorder;
  final Color focusColor;
  final Color hoverColor;
  final Color pressColor;
  final bool excludeFromSemantics;
  final ValueChanged<bool> onFocusChange;
  final bool autofocus;
  final FocusNode focusNode;
  final bool canRequestFocus;
  final _GetRectCallback getRectCallback;
  final _CheckContext debugCheckContext;

  @override
  _ListTileBackgroundState createState() => _ListTileBackgroundState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onDoubleTap != null) 'double tap',
      if (onLongPress != null) 'long press',
      if (onTapDown != null) 'tap down',
      if (onTapCancel != null) 'tap cancel',
    ];
    properties
        .add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'));
    properties.add(DiagnosticsProperty<MouseCursor>('mouseCursor', mouseCursor,
        defaultValue: MouseCursor.defer));
  }
}

enum _HighlightType {
  pressed,
  hover,
  focus,
}

class _ListTileBackgroundState extends State<_ListTileBackgroundStateWidget> {
  bool _hovering = false;
  Map<Type, Action<Intent>> _actionMap;
  Color _highlightColor;

  void _handleAction(ActivateIntent intent) {
    _handleTap(context);
  }

  @override
  void initState() {
    super.initState();
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _handleAction),
    };
    FocusManager.instance
        .addHighlightModeListener(_handleFocusHighlightModeChange);
  }

  @override
  void didUpdateWidget(_ListTileBackgroundStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isWidgetEnabled(widget) != _isWidgetEnabled(oldWidget)) {
      _handleHoverChange(_hovering);
      _updateFocusHighlights();
    }
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(_handleFocusHighlightModeChange);
    super.dispose();
  }

  Color getHighlightColorForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return widget.pressColor;
      case _HighlightType.focus:
        return widget.focusColor;
      case _HighlightType.hover:
        return widget.hoverColor;
    }
    assert(false, 'Unhandled $_HighlightType $type');
    return null;
  }

  Duration getFadeDurationForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return const Duration(milliseconds: 200);
      case _HighlightType.hover:
      case _HighlightType.focus:
        return const Duration(milliseconds: 50);
    }
    assert(false, 'Unhandled $_HighlightType $type');
    return null;
  }

  void updateHighlight(_HighlightType type, {@required bool value}) {
    switch (type) {
      case _HighlightType.pressed:
        if (widget.onHighlightChanged != null) widget.onHighlightChanged(value);
        break;
      case _HighlightType.hover:
        if (widget.onHover != null) widget.onHover(value);
        break;
      case _HighlightType.focus:
        break;
    }
    _setHighlightColor(value ? getHighlightColorForType(type) : null);
  }

  void _setHighlightColor(Color color) {
    setState(() {
      _highlightColor = color;
    });
  }

  void _handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      _updateFocusHighlights();
    });
  }

  bool get _shouldShowFocus {
    final NavigationMode mode =
        MediaQuery.of(context, nullOk: true)?.navigationMode ??
            NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && _hasFocus;
      case NavigationMode.directional:
        return _hasFocus;
    }
    assert(false, 'Navigation mode $mode not handled');
    return null;
  }

  void _updateFocusHighlights() {
    bool showFocus;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        showFocus = false;
        break;
      case FocusHighlightMode.traditional:
        showFocus = _shouldShowFocus;
        break;
    }
    updateHighlight(_HighlightType.focus, value: showFocus);
  }

  bool _hasFocus = false;
  void _handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    _updateFocusHighlights();
    if (widget.onFocusChange != null) {
      widget.onFocusChange(hasFocus);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    updateHighlight(_HighlightType.pressed, value: true);
    if (widget.onTapDown != null) {
      widget.onTapDown(details);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (enabled && _hovering) {
      updateHighlight(_HighlightType.hover, value: enabled);
    } else {
      updateHighlight(_HighlightType.pressed, value: false);
    }
  }

  void _handleTap(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    if (widget.onTapCancel != null) {
      widget.onTapCancel();
    }
    updateHighlight(_HighlightType.pressed, value: false);
  }

  void _handleDoubleTap() {
    if (widget.onDoubleTap != null) widget.onDoubleTap();
  }

  void _handleLongPress(BuildContext context) {
    if (widget.onLongPress != null) {
      widget.onLongPress();
    }
  }

  bool _isWidgetEnabled(_ListTileBackgroundStateWidget widget) {
    return widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null;
  }

  bool get enabled => _isWidgetEnabled(widget);

  void _handleMouseEnter(PointerEnterEvent event) => _handleHoverChange(true);
  void _handleMouseExit(PointerExitEvent event) => _handleHoverChange(false);
  void _handleHoverChange(bool hovering) {
    if (_hovering != hovering) {
      _hovering = hovering;
      updateHighlight(_HighlightType.hover, value: enabled && _hovering);
    }
  }

  bool get _canRequestFocus {
    final NavigationMode mode =
        MediaQuery.of(context, nullOk: true)?.navigationMode ??
            NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && widget.canRequestFocus;
      case NavigationMode.directional:
        return true;
    }
    assert(false, 'NavigationMode $mode not handled.');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.debugCheckContext(context));
    return Actions(
      actions: _actionMap,
      child: Focus(
        focusNode: widget.focusNode,
        canRequestFocus: _canRequestFocus,
        onFocusChange: _handleFocusUpdate,
        autofocus: widget.autofocus,
        child: MouseRegion(
          cursor: widget.mouseCursor,
          onEnter: enabled ? _handleMouseEnter : null,
          onExit: enabled ? _handleMouseExit : null,
          child: GestureDetector(
            onTapDown: enabled ? _handleTapDown : null,
            onTapUp: enabled ? _handleTapUp : null,
            onTap: enabled ? () => _handleTap(context) : null,
            onTapCancel: enabled ? _handleTapCancel : null,
            onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
            onLongPress: widget.onLongPress != null
                ? () => _handleLongPress(context)
                : null,
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: widget.excludeFromSemantics,
            child: Container(
              child: widget.child,
              decoration: BoxDecoration(
                color: _highlightColor,
                border: widget.customBorder,
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
