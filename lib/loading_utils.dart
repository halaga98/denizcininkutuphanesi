import 'package:flutter/material.dart';

class LoadingUtils {
  BuildContext context;

  LoadingUtils(this.context);

  // this is where you would do your fullscreen loading
  Future<void> startLoading() async {
    showGeneralDialog<void>(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: SimpleDialog(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              children: <Widget>[
                SizedBox(
                  child: Center(child: CircularProgressIndicator()),
                  height: 50.0,
                  width: 50.0,
                ),
              ],
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return SizedBox.shrink();
        });
  }

  Future<void> stopLoading() async {
    Navigator.of(context).pop();
  }

  Future<void> showError(Object error) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: Colors.red,
        content: Text(""),
      ),
    );
  }
}
