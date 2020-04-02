library flutter_ui_utils;

// Core
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Plugins
import 'package:progress_hud/progress_hud.dart';

class Dialogs {
  static bool _isSpinnerShown = false;

  /// Shows a basic alert with Ok button on it
  ///
  /// `context` The context of your current page
  ///
  /// `body` The body of the dialog
  ///
  /// `buttonName` The name of the button hides the dialog. Default is OK
  ///
  /// `onResolve` CallBack function that calls back when hit the resolve button
  ///
  /// `onDismiss` CallBack function that calls back
  /// when the dialog dismissed = not hit OK
  static Future<void> alert(
    BuildContext context,
    String body,
    {
      String title = 'Alert',
      String btnName = 'OK',
      bool showCancel = false,
      VoidCallback onResolve,
      VoidCallback onDismiss
    }
  ) {
    assert(context != null);
    assert(body != null);
    assert(title != null);
    assert(btnName != null);

    bool clicked = false;
    debugPrint('title is: $title');
    debugPrint('btnName is: $btnName');

    AlertDialog dialog = new AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: <Widget>[
          FlatButton(child: Text(btnName), onPressed: () {
            Navigator.of(context).pop(); // Hides the Alert
            clicked = true;

            if (onResolve != null) {
              onResolve();
            }
          }),
          showCancel ?
            FlatButton(child: new Text('Cancel'), onPressed: () {
              Navigator.of(context).pop(); // Hides the Alert
              clicked = true;

              if (onDismiss != null){
                onDismiss();
              }
            })
          :
            SizedBox()
        ]
    );

    return showDialog(context: context, builder: (BuildContext context) => dialog).then((val) {
      if (!clicked) {
        debugPrint('clicked outside');

        if (onDismiss != null){
          onDismiss();
        }
      }
    });
  }

  /// Show a dialog with loading circle indicator
  ///
  /// `context` The context of your current page
  ///
  /// `secondsToHide` The number of seconds the dialog shown. Default is 30sec
  ///
  /// `backgroundColor` Background color of the rest of the screen except dialog
  ///
  /// `color` Color of the text
  ///
  /// `containerColor` Color of the dialog itself
  ///
  /// `borderRadius` The angle of circular border of the dialog
  ///
  /// `text` Text written by the dialog
  static void loadingSpinner(BuildContext context, {
    int secondsToHide = 0,
    Color backgroundColor,
    Color color,
    Color containerColor,
    double borderRadius,
    String text = ''
  }) {
    assert(secondsToHide != null);
    assert(text != null);

    ProgressHUD progressSpinner = ProgressHUD(
        backgroundColor: backgroundColor != null ? backgroundColor : Colors.black12,
        color: color != null ? color : Theme.of(context).primaryColorLight,
        containerColor: containerColor != null ? containerColor : Colors.transparent,
        borderRadius: borderRadius != null ? borderRadius : 5.0,
        text: text != '' ? text : 'Loading...'
    );

    showDialog(context: context, barrierDismissible: false, builder: (BuildContext context) => progressSpinner);
    _isSpinnerShown = true;

    if (secondsToHide > 0) {
      // This is like setTimeout in JavaScript
      Future.delayed(Duration(seconds: secondsToHide), () => hideLoadingSpinner(context));
    } else {
      print('There is no secondsToHide');
      Future.delayed(const Duration(seconds: 30), () => hideLoadingSpinner(context));
    }
  }

  /// Hides the loading dialog manually
  ///
  /// `context` The same context received by the showLoadingSpinner function
  static void hideLoadingSpinner(BuildContext context) {
    if (_isSpinnerShown){
      Navigator.pop(context);

      // Toggle to false the flag of the loading spinner
      _isSpinnerShown = false;
    }
  }

  /// Showing prompt dialog, which is a dialog with textField inside it
  ///
  /// `context` The context of the page you call from
  ///
  /// `title` The title of the dialog
  ///
  /// `body` The body of the dialog (text on top of the textField)
  ///
  /// `placeholder` A text that written in the TextField and
  ///  disappears when the user start to type
  ///
  /// `textCtrl` A custom text controller
  ///
  /// `keyboardType` The type of the keyboard (such as email, numbers)
  ///  default is text
  ///
  /// `showCancelButton` A switch you can set,
  /// if you want to see the Cancel button of the dialog. default is false
  static Future<String> prompt(
      BuildContext context,
      String body,
      {
        String title = 'Attention',
        String placeholder = 'Write something',
        bool isPass = false,
        TextInputType keyboardType
      }
  ) {
    assert(context != null);
    assert(body != null);

    String data = '';
    bool isOk = false;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: Text(title),
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 25, bottom: 20),
                    child: Text(body)
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(25, 0, 25, 10),
                    child: TextField(
                        keyboardType: keyboardType,
                        obscureText: isPass,
                        autofocus: true,
                        decoration: InputDecoration(hintText: placeholder),
                        onChanged: (String text) => data = text
                    )
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                          child: Text('OK'),
                          onPressed: () {
                            isOk = true;
                            Navigator.of(context).pop();
                          }
                      ),
                      FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            isOk = false;
                            Navigator.of(context).pop();
                          }
                      )
                    ]
                )
              ]
          );
        }
    ).then((val) {
      if (isOk)
        return data;

      // Typed nothing
      return null;
    });
  }
  ///

  /// Showing a dialog with multiple buttons with custom functions in each
  /// `context` The context of your current page
  ///
  /// `body` The body of the confirm alert
  ///
  /// `title` The title you want to write on
  ///
  /// `buttons` Map<String, Function> - The name of the button (String),
  /// The function that you want to run after (Function)
  static void confirmDialog(BuildContext context, String body, String title, { Map<String, void Function()> buttons }) {
    var widgetArr = <Widget>[];

    if (buttons.isNotEmpty) {
      buttons.forEach((String buttonName, Function funToRun) {
        widgetArr.add(
            new FlatButton(child: Text(buttonName), onPressed: () {
              // Running the function that commited to this button
              Navigator.of(context).pop(); // Hides the Alert
              funToRun();
            })
        );
      });
    } else {
      widgetArr[0] = new FlatButton(child: Text('OK'), onPressed: () {
        Navigator.of(context).pop(); // Hides the Alert
      });

      widgetArr[0] = new FlatButton(child: Text('Cancel'), onPressed: () {
        Navigator.of(context).pop(); // Hides the Alert
      });
    }

    AlertDialog dialog = new AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: widgetArr
    );

    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  /// Calculate the number is percent of another number
  ///
  /// `whole` The 100% number of yours
  ///
  /// `targetPercent` How much percent you need from the whole
  ///
  /// Returns the number is x% of the whole number
  /// For example calculatePercent(100, 10) will return 10)
  static double calculatePercent(double whole, double targetPercent) {
    return (targetPercent * whole) / 100;
  }

  /// Showing alert dialog with radio button tiles inside it
  ///
  /// `context` The context of the page you call from
  ///
  /// `title` The title of the dialog (optional)
  ///
  /// `body` The body of the dialog (a little brief before the tiles, optional)
  ///
  /// `options` A map with the title of the button as key,
  /// and the ChoiceData as value
  ///
  /// `onSubmit` a function to run after the user choose a button
  static void multiChoiceAlert({
    @required BuildContext context,
    String title,
    String body,
    @required Map<String, ChoiceData> options,
    @required CallBackFunc onSubmit
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ChoicesDialog(
            title: title,
            body: body,
            options: options,
            onSubmit: onSubmit
        );
      }
    );
  }
}

class ChoiceData {
  dynamic data;
  bool isFocused;

  /// Object of Dialogs.multiChoiceAlert radio tiles alert
  ///
  /// `isFocused` is this button focused ?
  ///
  /// `data` a data to send via callback when the user chooses this button
  ChoiceData({ this.isFocused = false, @required this.data });
}

typedef void CallBackFunc(value);
class _ChoicesDialog extends StatefulWidget {
  final String title;
  final String body;
  final Map<String, ChoiceData> options;
  final CallBackFunc onSubmit;

  /// Title of the dialog's body widget
  ///
  /// `title` The title of the alert (optional, default: 'Pick one')
  ///
  /// `body` The body string of the alert
  ///
  /// `options` All the options map<Title, returnData>
  ///
  /// `onSubmit` A function that returns the value the user chose
  /// after the dialog resolves
  _ChoicesDialog({
    this.title = 'Pick one',
    this.body,
    @required this.options,
    @required this.onSubmit
  }) :
        assert(title != null),
        assert(options != null),
        assert(onSubmit != null);

  @override
  _ChoicesDialogState createState() => _ChoicesDialogState();
}

class _ChoicesDialogState extends State<_ChoicesDialog> {
  String _selected;

  // The function that calls the callback after the dialog hide
  void submit() {
    Navigator.pop(context);
    widget.onSubmit(widget.options[_selected].data);
  }

  // Tiles generator
  List<Widget> _buildList() {
    bool alreadyFocused = false;
    List<Widget> content = [
      widget.body.isNotEmpty ?
        Padding(
          padding: EdgeInsets.only(left: 25, bottom: 5),
          child: Text(widget.body)
        )
      :
        SizedBox()
    ];

    widget.options.forEach((String name, ChoiceData value) {
      if (!alreadyFocused && value.isFocused) {
        setState(() => _selected = name);
        alreadyFocused = true;
      }

      content.add(
        RadioListTile(
            groupValue: _selected,
            value: value.data,
            title: Text(name),
            onChanged: (changedVal) {
              setState(() => _selected = name);
              submit();
            }
        ),
      );
    });

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Text(widget.title),
        children: _buildList()
    );
  }
}

class FavoritesWidgets {
  /// Create an appbar with subtitle in it
  ///
  /// `bar` Your [AppBar] with anything you want inside it
  ///
  /// `title` The title of the AppBar
  ///
  /// `subtitle` The subtitle that under the title
  ///
  /// `textColor` The color of the title and subtitle
  ///
  /// `titleFontSize` The custom size of the title
  ///
  /// `subtitleFontSize` The custom size of the subtitle
  static AppBar appBarWithSubtitle(
    AppBar bar, String title, String subtitle,
    { Color textColor, double titleFontSize = 18, double subtitleFontSize = 12 }
  ) {
    return AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                title,
                style: TextStyle(
                    color: textColor != null ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize != 0 ? titleFontSize : 18
                )
            ),
            Text(
              subtitle,
              style: TextStyle(
                  color: textColor != null ? Colors.white : textColor,
                  fontSize: subtitleFontSize != 0 ? subtitleFontSize : 12
              )
            )
          ]
        ),
        leading: bar.leading != null ?
          Padding(padding: const EdgeInsets.all(5.0), child: bar.leading)
        :
          bar.leading
        ,
        actions: bar.actions,
        actionsIconTheme: bar.actionsIconTheme,
        automaticallyImplyLeading: bar.automaticallyImplyLeading,
        backgroundColor: bar.backgroundColor,
        bottom: bar.bottom,
        bottomOpacity: bar.bottomOpacity,
        brightness: bar.brightness,
        centerTitle: bar.centerTitle,
        elevation: bar.elevation,
        flexibleSpace: bar.flexibleSpace,
        iconTheme: bar.iconTheme,
        key: bar.key,
        primary: bar.primary,
        shape: bar.shape,
        textTheme: bar.textTheme,
        titleSpacing: bar.titleSpacing,
        toolbarOpacity: bar.toolbarOpacity
    );
  }
}

class HexColor extends Color {
  /// Getting the Color Object from an Hex color string
  ///
  /// `hexColor` const dart [String]
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  /// Getting the hex string from a Color class
  ///
  /// `c` const dart [Color]
  static String getHexFromColor(Color c) {
    String hexVal = c.value.toRadixString(16);
    return '#$hexVal';
  }

  /// You can use `hexColor` hex string instead of the dart's [Color] class
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}