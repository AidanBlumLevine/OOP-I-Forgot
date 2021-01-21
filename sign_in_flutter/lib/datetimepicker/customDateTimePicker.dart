import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'datetimemodel.dart';
import 'package:flutter_datetime_picker/src/i18n_model.dart';

typedef DateChangedCallback(DateTime time);
typedef DateCancelledCallback();
typedef String StringAtIndexCallBack(int index);

class CustomDatePicker {
  //pickerModel: Time12hPickerModel(currentTime: currentTime, locale: locale)));

  static Future<DateTime> showCustomDateTimePicker(
    BuildContext context, {
    bool showTitleActions: true,
    DateTime minTime,
    DateTime maxTime,
    DateChangedCallback onChanged,
    DateChangedCallback onConfirm,
    DateCancelledCallback onCancel,
    locale: LocaleType.en,
    DateTime currentTime,
    DatePickerTheme theme,
  }) async {
    return await Navigator.push(
        context,
        new _DatePickerRoute(
            showTitleActions: showTitleActions,
            onChanged: onChanged,
            onConfirm: onConfirm,
            onCancel: onCancel,
            locale: locale,
            theme: theme,
            barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            pickerModel: CustomDateTimePickerModel(currentTime: currentTime, minTime: minTime, maxTime: maxTime, locale: locale)));
  }

  static Future<DateTime> showCustomTimePicker(
    BuildContext context, {
    bool showTitleActions: true,
    DateChangedCallback onChanged,
    DateChangedCallback onConfirm,
    DateCancelledCallback onCancel,
    locale: LocaleType.en,
    DateTime currentTime,
    DatePickerTheme theme,
  }) async {
    return await Navigator.push(
        context,
        new _DatePickerRoute(
            showTitleActions: showTitleActions,
            onChanged: onChanged,
            onConfirm: onConfirm,
            onCancel: onCancel,
            locale: locale,
            theme: theme,
            barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            pickerModel: CustomTimePickerModel(currentTime: currentTime, locale: locale)));
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.showTitleActions,
    this.onChanged,
    this.onConfirm,
    this.onCancel,
    theme,
    this.barrierLabel,
    this.locale,
    RouteSettings settings,
    pickerModel,
  })  : this.pickerModel = pickerModel ?? DatePickerModel(),
        this.theme = theme ?? DatePickerTheme(),
        super(settings: settings);

  final bool showTitleActions;
  final DateChangedCallback onChanged;
  final DateChangedCallback onConfirm;
  final DateCancelledCallback onCancel;
  final DatePickerTheme theme;
  final LocaleType locale;
  final CommonPickerModel pickerModel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(
        onChanged: onChanged,
        locale: this.locale,
        route: this,
        pickerModel: pickerModel,
      ),
    );
    ThemeData inheritTheme = Theme.of(context, shadowThemeOnly: true);
    if (inheritTheme != null) {
      bottomSheet = new Theme(data: inheritTheme, child: bottomSheet);
    }
    return bottomSheet;
  }
}

class _DatePickerComponent extends StatefulWidget {
  _DatePickerComponent({Key key, @required this.route, this.onChanged, this.locale, this.pickerModel});

  final DateChangedCallback onChanged;

  final _DatePickerRoute route;

  final LocaleType locale;

  final CommonPickerModel pickerModel;

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<_DatePickerComponent> {
  FixedExtentScrollController leftScrollCtrl, middleScrollCtrl, rightScrollCtrl, extraScrollCtrl;

  @override
  void initState() {
    super.initState();
    refreshScrollOffset();
  }

  void refreshScrollOffset() {
//    print('refreshScrollOffset ${widget.pickerModel.currentRightIndex()}');
    leftScrollCtrl = new FixedExtentScrollController(initialItem: widget.pickerModel.currentLeftIndex());
    middleScrollCtrl = new FixedExtentScrollController(initialItem: widget.pickerModel.currentMiddleIndex());
    rightScrollCtrl = new FixedExtentScrollController(initialItem: widget.pickerModel.currentRightIndex());
    widget.pickerModel.layoutProportions().length > 3
        ? extraScrollCtrl = new FixedExtentScrollController(initialItem: widget.pickerModel.currentExtraIndex())
        : null;
  }

  @override
  Widget build(BuildContext context) {
    DatePickerTheme theme = widget.route.theme;
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          final double bottomPadding = MediaQuery.of(context).padding.bottom;
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(widget.route.animation.value, theme,
                  showTitleActions: widget.route.showTitleActions, bottomPadding: bottomPadding),
              child: GestureDetector(
                child: Material(
                  color: theme.backgroundColor ?? Colors.white,
                  child: _renderPickerView(theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged(widget.pickerModel.finalTime());
    }
  }

  Widget _renderPickerView(DatePickerTheme theme) {
    Widget itemView = _renderItemView(theme);
    if (widget.route.showTitleActions) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(theme),
          itemView,
        ],
      );
    }
    return itemView;
  }

  Widget _renderColumnView(ValueKey key, DatePickerTheme theme, StringAtIndexCallBack stringAtIndexCB, ScrollController scrollController,
      int layoutProportion, ValueChanged<int> selectedChangedWhenScrolling, ValueChanged<int> selectedChangedWhenScrollEnd) {
    return Expanded(
      flex: layoutProportion,
      child: Container(
          padding: EdgeInsets.all(8.0),
          height: theme.containerHeight,
          decoration: BoxDecoration(color: theme.backgroundColor ?? Colors.white),
          child: NotificationListener(
              onNotification: (ScrollNotification notification) {
                if (notification.depth == 0 &&
                    selectedChangedWhenScrollEnd != null &&
                    notification is ScrollEndNotification &&
                    notification.metrics is FixedExtentMetrics) {
                  final FixedExtentMetrics metrics = notification.metrics;
                  final int currentItemIndex = metrics.itemIndex;
                  selectedChangedWhenScrollEnd(currentItemIndex);
                }
                return false;
              },
              child: CupertinoPicker.builder(
                  key: key,
                  backgroundColor: theme.backgroundColor ?? Colors.white,
                  scrollController: scrollController,
                  itemExtent: theme.itemHeight,
                  onSelectedItemChanged: (int index) {
                    selectedChangedWhenScrolling(index);
                  },
                  useMagnifier: true,
                  itemBuilder: (BuildContext context, int index) {
                    final content = stringAtIndexCB(index);
                    if (content == null) {
                      return null;
                    }
                    return Container(
                      height: theme.itemHeight,
                      alignment: Alignment.center,
                      child: Text(
                        content,
                        style: theme.itemStyle,
                        textAlign: TextAlign.start,
                      ),
                    );
                  }))),
    );
  }

  Widget _renderItemView(DatePickerTheme theme) {
    return Container(
      color: theme.backgroundColor ?? Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              child: _renderColumnView(ValueKey(widget.pickerModel.currentLeftIndex()), theme, widget.pickerModel.leftStringAtIndex, leftScrollCtrl,
                  widget.pickerModel.layoutProportions()[0], (index) {
            widget.pickerModel.setLeftIndex(index);
          }, (index) {
            setState(() {
              refreshScrollOffset();
              _notifyDateChanged();
            });
          })),
          Text(
            widget.pickerModel.leftDivider(),
            style: theme.itemStyle,
          ),
          Container(
              child: _renderColumnView(ValueKey(widget.pickerModel.currentLeftIndex()), theme, widget.pickerModel.middleStringAtIndex,
                  middleScrollCtrl, widget.pickerModel.layoutProportions()[1], (index) {
            widget.pickerModel.setMiddleIndex(index);
          }, (index) {
            setState(() {
              refreshScrollOffset();
              _notifyDateChanged();
            });
          })),
          Text(
            widget.pickerModel.rightDivider(),
            style: theme.itemStyle,
          ),
          Container(
              child: _renderColumnView(ValueKey(widget.pickerModel.currentMiddleIndex() * 100 + widget.pickerModel.currentLeftIndex()), theme,
                  widget.pickerModel.rightStringAtIndex, rightScrollCtrl, widget.pickerModel.layoutProportions()[2], (index) {
            widget.pickerModel.setRightIndex(index);
            _notifyDateChanged();
          }, null)),
          Text(
            widget.pickerModel.extraDivider(),
            style: theme.itemStyle,
          ),
          widget.pickerModel.layoutProportions().length > 3
              ? Container(
                  child: _renderColumnView(ValueKey(widget.pickerModel.currentMiddleIndex() * 50 + widget.pickerModel.currentLeftIndex()), theme,
                      widget.pickerModel.extraStringAtIndex, extraScrollCtrl, widget.pickerModel.layoutProportions()[3], (index) {
                  widget.pickerModel.setExtraIndex(index);
                  _notifyDateChanged();
                }, null))
              : Container(),
        ],
      ),
    );
  }

  // Title View
  Widget _renderTitleActionsView(DatePickerTheme theme) {
    return Container(
        height: theme.titleHeight,
        decoration: BoxDecoration(
          color: theme.headerColor ?? theme.backgroundColor ?? Colors.white,
        ),
        child: Column(children: [
          SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: theme.titleHeight,
                  child: CupertinoButton(
                    pressedOpacity: 0.3,
                    padding: EdgeInsets.only(left: 16, top: 0),
                    child: Text(
                      'Cancel',
                      style: theme.cancelStyle,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (widget.route.onCancel != null) {
                        widget.route.onCancel();
                      }
                    },
                  ),
                ),
                theme.center ?? Container(),
                Container(
                  height: theme.titleHeight,
                  child: CupertinoButton(
                    pressedOpacity: 0.3,
                    padding: EdgeInsets.only(right: 16, top: 0),
                    child: Text(
                      'Done',
                      style: theme.doneStyle,
                    ),
                    onPressed: () {
                      Navigator.pop(context, widget.pickerModel.finalTime());
                      if (widget.route.onConfirm != null) {
                        widget.route.onConfirm(widget.pickerModel.finalTime());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          theme.belowCenter ?? Container(),
        ]));
  }
}

class DatePickerTheme with DiagnosticableTreeMixin {
  final TextStyle cancelStyle;
  final TextStyle doneStyle;
  final TextStyle itemStyle;
  final Widget center, belowCenter;
  final Color backgroundColor;
  final Color headerColor;
  final String title;
  final double containerHeight;
  final double titleHeight;
  final double itemHeight;

  const DatePickerTheme({
    this.cancelStyle = const TextStyle(color: Colors.black54, fontSize: 16),
    this.center,
    this.belowCenter,
    this.doneStyle = const TextStyle(color: Colors.blue, fontSize: 16),
    this.itemStyle = const TextStyle(color: Color(0xFF000046), fontSize: 18),
    this.backgroundColor = Colors.white,
    this.headerColor,
    this.title = '',
    this.containerHeight = 210.0,
    this.titleHeight = 44.0,
    this.itemHeight = 36.0,
  });
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, this.theme, {this.itemCount, this.showTitleActions, this.bottomPadding = 0});

  final double progress;
  final int itemCount;
  final bool showTitleActions;
  final DatePickerTheme theme;
  final double bottomPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = theme.containerHeight;
    if (showTitleActions) {
      maxHeight += theme.titleHeight;
    }

    return new BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth, minHeight: 0.0, maxHeight: maxHeight + bottomPadding);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
