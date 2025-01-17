library fa_stepper;

// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';

//   * mobile horizontal mode with adding/removing steps
//   * alternative labeling
//   * stepper feedback in the case of high-latency interactions

/// The state of a [FAStep] which is used to control the style of the circle and
/// text.
///
/// See also:
///
///  * [FAStep]
enum FAStepstate {
  /// A step that displays its index in its circle.
  indexed,

  /// A step that displays a pencil icon in its circle.
  editing,

  /// A step that displays a tick icon in its circle.
  complete,

  /// A step that is disabled and does not to react to taps.
  disabled,

  /// A step that is currently having an error. e.g. the user has submitted wrong
  /// input.
  error,
}

/// Defines the [FAStepper]'s main axis.
enum FAStepperType {
  /// A vertical layout of the steps with their content in-between the titles.
  vertical,

  /// A horizontal layout of the steps with their content below the titles.
  horizontal,
}

enum FAStepperTitleIconArrange { row, column }

const TextStyle _kStepStyle = TextStyle(
  fontSize: 12.0,
  color: Colors.white,
);
const Color _kErrorLight = Colors.red;
final Color _kErrorDark = Colors.red.shade400;
const Color _kCircleActiveLight = Colors.white;
const Color _kCircleActiveDark = Colors.black87;
const Color _kDisabledLight = Colors.black38;
const Color _kDisabledDark = Colors.white38;
const double _kStepSize = 24.0;
const double _kTriangleHeight = _kStepSize * 0.866025; // Triangle height. sqrt(3.0) / 2.0

/// A material step used in [FAStepper]. The step can have a title and subtitle,
/// an icon within its circle, some content and a state that governs its
/// styling.
///
/// See also:
///
///  * [FAStepper]
///  * <https://material.io/archive/guidelines/components/steppers.html>
@immutable
class FAStep {
  /// Creates a step for a [FAStepper].
  ///
  /// The [title], [content], and [state] arguments must not be null.
  const FAStep({
    required this.title,
    this.subtitle,
    required this.content,
    this.state = FAStepstate.indexed,
    this.isActive = false,
  });

  /// The title of the step that typically describes it.
  final Widget title;

  /// The subtitle of the step that appears below the title and has a smaller
  /// font size. It typically gives more details that complement the title.
  ///
  /// If null, the subtitle is not shown.
  final Widget? subtitle;

  /// The content of the step that appears below the [title] and [subtitle].
  ///
  /// Below the content, every step has a 'continue' and 'cancel' button.
  final Widget content;

  /// The state of the step which determines the styling of its components
  /// and whether steps are interactive.
  final FAStepstate state;

  /// Whether or not the step is active. The flag only influences styling.
  final bool isActive;
}

/// A material stepper widget that displays progress through a sequence of
/// steps. Steppers are particularly useful in the case of forms where one step
/// requires the completion of another one, or where multiple steps need to be
/// completed in order to submit the whole form.
///
/// The widget is a flexible wrapper. A parent class should pass [currentStep]
/// to this widget based on some logic triggered by the three callbacks that it
/// provides.
///
/// See also:
///
///  * [FAStep]
///  * <https://material.io/archive/guidelines/components/steppers.html>
class FAStepper extends StatefulWidget {
  /// Creates a stepper from a list of steps.
  ///
  /// This widget is not meant to be rebuilt with a different list of steps
  /// unless a key is provided in order to distinguish the old stepper from the
  /// new one.
  ///
  /// The [steps], [type], and [currentStep] arguments must not be null.
  const FAStepper({
    Key? key,
    required this.steps,
    this.physics,
    this.type = FAStepperType.vertical,
    this.titleIconArrange = FAStepperTitleIconArrange.column,
    this.stepNumberColor = IposColors.stepEdit,
    this.currentStep = 0,
    this.titleHeight = 66.0,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepCancel,
    this.contentPaddingWhenHorizontal = EdgeInsets.zero,
    this.controlsBuilder,
  })  : assert(0 <= currentStep && currentStep < steps.length),
        super(key: key);

  /// The steps of the stepper whose titles, subtitles, icons always get shown.
  ///
  /// The length of [steps] must not change.
  final List<FAStep> steps;

  /// How the stepper's scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to
  /// animate after the user stops dragging the scroll view.
  ///
  /// If the stepper is contained within another scrollable it
  /// can be helpful to set this property to [ClampingScrollPhysics].
  final ScrollPhysics? physics;

  /// The type of stepper that determines the layout. In the case of
  /// [FAStepperType.horizontal], the content of the current step is displayed
  /// underneath as opposed to the [FAStepperType.vertical] case where it is
  /// displayed in-between.
  final FAStepperType type;

  final FAStepperTitleIconArrange titleIconArrange;

  final Color stepNumberColor;

  /// The index into [steps] of the current step whose content is displayed.
  final int currentStep;

  final double titleHeight;

  /// The callback called when a step is tapped, with its index passed as
  /// an argument.
  final ValueChanged<int>? onStepTapped;

  /// The callback called when the 'continue' button is tapped.
  ///
  /// If null, the 'continue' button will be disabled.
  final VoidCallback? onStepContinue;

  /// The callback called when the 'cancel' button is tapped.
  ///
  /// If null, the 'cancel' button will be disabled.
  final VoidCallback? onStepCancel;

  /// Padding around the content of each step
  final EdgeInsets contentPaddingWhenHorizontal;

  /// The callback for creating custom controls.
  ///
  /// If null, the default controls from the current theme will be used.
  ///
  /// This callback which takes in a context and two functions,[onStepContinue]
  /// and [onStepCancel]. These can be used to control the stepper.
  ///
  /// {@tool snippet --template=stateless_widget_scaffold}
  /// Creates a stepper control with custom buttons.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Stepper(
  ///     controlsBuilder:
  ///       (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
  ///          return Row(
  ///            children: <Widget>[
  ///              FlatButton(
  ///                onPressed: onStepContinue,
  ///                child: const Text('CONTINUE'),
  ///              ),
  ///              FlatButton(
  ///                onPressed: onStepCancel,
  ///                child: const Text('CANCEL'),
  ///              ),
  ///            ],
  ///          );
  ///       },
  ///     steps: const <Step>[
  ///       Step(
  ///         title: Text('A'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///       Step(
  ///         title: Text('B'),
  ///         content: SizedBox(
  ///           width: 100.0,
  ///           height: 100.0,
  ///         ),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  final ControlsWidgetBuilder? controlsBuilder;

  @override
  _FAStepperState createState() => _FAStepperState();
}

class _FAStepperState extends State<FAStepper> with TickerProviderStateMixin {
  late List<GlobalKey> _keys;
  final Map<int, FAStepstate> _oldStates = <int, FAStepstate>{};

  @override
  void initState() {
    super.initState();
    _keys = List<GlobalKey>.generate(
      widget.steps.length,
      (int i) => GlobalKey(),
    );

    for (var i = 0; i < widget.steps.length; i += 1) _oldStates[i] = widget.steps[i].state;
  }

  @override
  void didUpdateWidget(FAStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.steps.length == oldWidget.steps.length);

    for (var i = 0; i < oldWidget.steps.length; i += 1) _oldStates[i] = oldWidget.steps[i].state;
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  bool _isCurrent(int index) {
    return widget.currentStep == index;
  }

  bool _isDark() {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget _buildLine(bool visible) {
    return Container(
      width: visible ? 1.0 : 0.0,
      height: 16.0,
      color: Colors.grey.shade400,
    );
  }

  Widget? _buildCircleChild(int index, bool oldState) {
    final state = oldState ? _oldStates[index] : widget.steps[index].state;
    final isDarkActive = _isDark() && widget.steps[index].isActive;
    assert(state != null);
    switch (state) {
      case FAStepstate.indexed:
      case FAStepstate.disabled:
        return Text(
          '${index + 1}',
          style: isDarkActive ? _kStepStyle.copyWith(color: Colors.black87) : _kStepStyle,
        );
      case FAStepstate.editing:
        return Icon(
          Icons.edit,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
          size: 18.0,
        );
      case FAStepstate.complete:
        return Icon(
          Icons.check,
          color: isDarkActive ? _kCircleActiveDark : _kCircleActiveLight,
          size: 18.0,
        );
      case FAStepstate.error:
        return const Text('!', style: _kStepStyle);
      default:
        return null;
    }
  }

  Color _circleColor(int index) {
    if (!_isDark()) {
      if (widget.steps[index].state == FAStepstate.complete) {
        return IposColors.stepCompleteColor;
      }
      return widget.steps[index].isActive
          ? widget.stepNumberColor //IposColors.stepEdit
          : Colors.black38;
    } else {
      if (widget.steps[index].state == FAStepstate.complete) {
        return IposColors.stepCompleteColor;
      }
      return widget.steps[index].isActive
          ? widget.stepNumberColor //IposColors.stepEdit
          : Colors.black38;
    }
  }

  Widget _buildCircle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: kThemeAnimationDuration,
        decoration: BoxDecoration(
          color: _circleColor(index),
          shape: BoxShape.circle,
        ),
        child: Center(
          child:
              _buildCircleChild(index, oldState && widget.steps[index].state == FAStepstate.error),
        ),
      ),
    );
  }

  Widget _buildTriangle(int index, bool oldState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: _kStepSize,
      height: _kStepSize,
      child: Center(
        child: SizedBox(
          width: _kStepSize,
          height: _kTriangleHeight, // Height of 24dp-long-sided equilateral triangle.
          child: CustomPaint(
            painter: _TrianglePainter(
              color: _isDark() ? _kErrorDark : _kErrorLight,
            ),
            child: Align(
              alignment: const Alignment(0.0, 0.8), // 0.8 looks better than the geometrical 0.33.
              child: _buildCircleChild(
                  index, oldState && widget.steps[index].state != FAStepstate.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    if (widget.steps[index].state != _oldStates[index]) {
      return AnimatedCrossFade(
        firstChild: _buildCircle(index, true),
        secondChild: _buildTriangle(index, true),
        firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.fastOutSlowIn,
        crossFadeState: widget.steps[index].state == FAStepstate.error
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: kThemeAnimationDuration,
      );
    } else {
      if (widget.steps[index].state != FAStepstate.error)
        return _buildCircle(index, false);
      else
        return _buildTriangle(index, false);
    }
  }

  Widget _buildVerticalControls() {
    if (widget.controlsBuilder != null)
      return widget.controlsBuilder!(
          context,
          ControlsDetails(
            currentStep: widget.currentStep,
            stepIndex: widget.currentStep, // Might blow out in the future
            onStepContinue: widget.onStepContinue,
            onStepCancel: widget.onStepCancel,
          ));

    Color? cancelColor;

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        cancelColor = Colors.black54;
        break;
      case Brightness.dark:
        cancelColor = Colors.white70;
        break;
    }

    final themeData = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);

    // MirrorSystem mirrors = currentMirrorSystem();

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 48.0),
        child: Row(
          children: <Widget>[
            FlatButton(
              onPressed: widget.onStepContinue,
              color: _isDark() ? themeData.backgroundColor : themeData.primaryColor,
              textColor: Colors.white,
              textTheme: ButtonTextTheme.normal,
              child: Text(localizations.continueButtonLabel),
            ),
            Container(
              margin: const EdgeInsetsDirectional.only(start: 8.0),
              child: FlatButton(
                onPressed: widget.onStepCancel,
                textColor: cancelColor,
                textTheme: ButtonTextTheme.normal,
                child: Text(localizations.cancelButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _subtitleStyle(int index) {
    final themeData = Theme.of(context);
    final textTheme = themeData.textTheme;

    switch (widget.steps[index].state) {
      case FAStepstate.indexed:
      case FAStepstate.editing:
      case FAStepstate.complete:
        return textTheme.caption!;
      case FAStepstate.disabled:
        return textTheme.caption!.copyWith(color: _isDark() ? _kDisabledDark : _kDisabledLight);
      case FAStepstate.error:
        return textTheme.caption!.copyWith(color: _isDark() ? _kErrorDark : _kErrorLight);
    }
  }

  Widget _buildHeaderText(int index) {
    return (widget.titleIconArrange == FAStepperTitleIconArrange.column)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedDefaultTextStyle(
                style: (index == widget.currentStep)
                    ? TextStyle(color: Colors.blue, fontWeight: FontWeight.w800)
                    : TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.normal,
                      ), //_titleStyle(index),
                duration: kThemeAnimationDuration,
                curve: Curves.fastOutSlowIn,
                child: widget.steps[index].title,
              ),
              if (widget.steps[index].subtitle != null)
                Container(
                  margin: const EdgeInsets.only(top: 2.0),
                  child: AnimatedDefaultTextStyle(
                    style: _subtitleStyle(index),
                    duration: kThemeAnimationDuration,
                    curve: Curves.fastOutSlowIn,
                    child: widget.steps[index].subtitle!,
                  ),
                ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedDefaultTextStyle(
                style: (index == widget.currentStep)
                    ? TextStyle(color: Colors.blue, fontWeight: FontWeight.w800)
                    : TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.normal,
                      ), //_titleStyle(index),
                duration: kThemeAnimationDuration,
                curve: Curves.fastOutSlowIn,
                child: widget.steps[index].title,
              ),
              if (widget.steps[index].subtitle != null)
                Container(
                  margin: const EdgeInsets.only(top: 2.0),
                  child: AnimatedDefaultTextStyle(
                    style: _subtitleStyle(index),
                    duration: kThemeAnimationDuration,
                    curve: Curves.fastOutSlowIn,
                    child: widget.steps[index].subtitle!,
                  ),
                ),
            ],
          );
  }

  Widget _buildVerticalHeader(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Line parts are always added in order for the ink splash to
              // flood the tips of the connector lines.
              _buildLine(!_isFirst(index)),
              _buildIcon(index),
              _buildLine(!_isLast(index)),
            ],
          ),
          Container(
            margin: const EdgeInsetsDirectional.only(start: 12.0),
            child: _buildHeaderText(index),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: _isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: Column(
              children: <Widget>[
                widget.steps[index].content,
                _buildVerticalControls(),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isCurrent(index) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }

  Widget _buildVertical() {
    return ListView(
      shrinkWrap: true,
      physics: widget.physics,
      children: <Widget>[
        for (int i = 0; i < widget.steps.length; i += 1)
          Column(
            key: _keys[i],
            children: <Widget>[
              InkWell(
                onTap: widget.steps[i].state != FAStepstate.disabled
                    ? () {
                        // In the vertical case we need to scroll to the newly tapped
                        // step.
                        Scrollable.ensureVisible(
                          _keys[i].currentContext!,
                          curve: Curves.fastOutSlowIn,
                          duration: kThemeAnimationDuration,
                        );

                        widget.onStepTapped?.call(i);
                      }
                    : null,
                canRequestFocus: widget.steps[i].state != FAStepstate.disabled,
                child: _buildVerticalHeader(i),
              ),
              _buildVerticalBody(i),
            ],
          ),
      ],
    );
  }

  Widget _buildHorizontal() {
    final children = <Widget>[
      for (var i = 0; i < widget.steps.length; i += 1) ...<Widget>[
        InkResponse(
            onTap: widget.steps[i].state != FAStepstate.disabled
                ? () => widget.onStepTapped?.call(i)
                : null,
            canRequestFocus: widget.steps[i].state != FAStepstate.disabled,
            child: (widget.titleIconArrange == FAStepperTitleIconArrange.column)
                ? Row(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: 44.0,
                              child: Center(
                                child: _buildIcon(i),
                              ),
                            ),
                            Container(
                              // height: 24,
                              child: _buildHeaderText(i),
                            ),
                          ],
                        ),
                        if (!_isLast(i))
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            height: 1.0,
                            width: 18,
                            color: Colors.blue,
                          ),
                      ])
                : Row(
                    children: <Widget>[
                      Container(
                        height: 44.0,
                        child: Center(
                          child: _buildIcon(i),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsetsDirectional.only(start: 12.0),
                        child: _buildHeaderText(i),
                      ),
                      if (!_isLast(i))
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 1.0,
                          width: 18,
                          color: Colors.blue,
                        ),
                    ],
                  )),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            height: widget.titleHeight,
            // Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                physics: widget.physics,
                scrollDirection: Axis.horizontal,
                itemCount: children.length,
                itemBuilder: (BuildContext context, int index) => children[index])),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            padding: widget.contentPaddingWhenHorizontal,
            children: <Widget>[
              AnimatedSize(
                curve: Curves.fastOutSlowIn,
                duration: kThemeAnimationDuration,
                vsync: this,
                child: widget.steps[widget.currentStep].content,
              ),
              _buildVerticalControls(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(() {
      if (context.findAncestorWidgetOfExactType<FAStepper>() != null)
        throw FlutterError('Steppers must not be nested.\n'
            'The material specification advises that one should avoid embedding '
            'steppers within steppers. '
            'https://material.io/archive/guidelines/components/steppers.html#steppers-usage');
      return true;
    }());
    switch (widget.type) {
      case FAStepperType.vertical:
        return _buildVertical();
      case FAStepperType.horizontal:
        return _buildHorizontal();
    }
  }
}

// Paints a triangle whose base is the bottom of the bounding rectangle and its
// top vertex the middle of its top.
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({
    this.color,
  });

  final Color? color;

  @override
  bool hitTest(Offset point) => true; // Hitting the rectangle is fine enough.

  @override
  bool shouldRepaint(_TrianglePainter oldPainter) {
    return oldPainter.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.width;
    final halfBase = size.width / 2.0;
    final height = size.height;
    final points = <Offset>[
      Offset(0.0, height),
      Offset(base, height),
      Offset(halfBase, 0.0),
    ];

    canvas.drawPath(
      Path()..addPolygon(points, true),
      Paint()..color = color ?? Colors.black,
    );
  }
}
